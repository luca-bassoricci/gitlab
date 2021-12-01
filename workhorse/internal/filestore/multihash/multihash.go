// Package multihash is a concurrent multihasher.
//
// This package creates a global job queue for writing chunks of data to several
// different hash implementations.
//
// The goal is to minimise the time it takes to produce multiple hashes in the
// hope that given enough resources, the whole process takes almost the same
// amount of time as the slowest hash implementation supported.
//
// A global job queue is used to reduce the overhead associated with setting up
// workers for each multihash. This overhead would diminish the benefits of
// concurrently writing the data to each hash, therefore each multihash shares
// the same job queue but passes along their individual hash writer as part of
// the unit of work.
//
// To further improve efficiency and reduce GC pressure, a pool is used to avoid
// the cost of setting up each buffer and hash writer from scratch within a
// window to recycle them, when they would otherwise be destroyed.
package multihash

import (
	"bufio"
	"crypto/md5"
	"crypto/sha1"
	"crypto/sha256"
	"crypto/sha512"
	"encoding/hex"
	"fmt"
	"hash"
	"runtime"
	"sync"
)

// writeChunkSize is ideally the size of chunk we want to write at once when
// scheduling onto a worker. There's a certain overhead for the synchronization
// involved in distributing work to a worker. For smaller buffer, it's more
// efficient to write sequentially to each hash writer.
const writeChunkSize = 4 * 1024

var (
	names     = []string{"md5", "sha1", "sha256", "sha512"}
	factories = []func() hash.Hash{
		md5.New,
		sha1.New,
		sha256.New,
		sha512.New,
	}

	pool = sync.Pool{
		New: func() interface{} {
			return &hasher{buf: bufio.NewWriterSize(nil, writeChunkSize)}
		},
	}

	workCh = make(chan work, runtime.NumCPU())
)

// init sets up the global job queue.
func init() {
	for i := 0; i < runtime.NumCPU(); i++ {
		go func() {
			for {
				d := <-workCh
				// the hash interface's Write() does not return errors by design
				// as hashes are pure functions: https://pkg.go.dev/hash#Hash
				_, _ = d.h.Write(d.buf)
				d.wg.Done()
			}
		}()
	}
}

type Writer struct {
	h *hasher
}

type work struct {
	h   hash.Hash
	buf []byte
	wg  *sync.WaitGroup
}

func New() *Writer {
	w := &Writer{}
	w.h = pool.Get().(*hasher)
	w.h.reset()

	return w
}

func (w *Writer) Write(p []byte) (n int, err error) {
	if w.h == nil {
		return 0, fmt.Errorf("multihash writer is closed")
	}

	return w.h.buf.Write(p)
}

func (w *Writer) Close() {
	if w.h == nil {
		return
	}

	pool.Put(w.h)
	w.h = nil
}

func (w *Writer) Hashes() map[string]string {
	if w.h == nil {
		return nil
	}

	_ = w.h.buf.Flush()

	return finish(w.h.hashes)
}

type hasher struct {
	buf     *bufio.Writer
	hashes  []hash.Hash
	writeWg sync.WaitGroup
}

func (h *hasher) reset() {
	h.buf.Reset(h)

	if h.hashes == nil {
		h.hashes = make([]hash.Hash, 0, len(factories))
		for _, factory := range factories {
			h.hashes = append(h.hashes, factory())
		}
	} else {
		for _, hash := range h.hashes {
			hash.Reset()
		}
	}
}

func (h *hasher) Write(p []byte) (n int, err error) {
	// for smaller buffers, we write directly to the hash implementations
	if len(p) < writeChunkSize {
		for _, hasher := range h.hashes {
			_, _ = hasher.Write(p)
		}

		return len(p), nil
	}

	// for larger buffers, we distribute the work to the workers. We have to
	// wait for all to complete because p is a shared buffer.
	h.writeWg.Add(len(h.hashes))
	for _, hasher := range h.hashes {
		workCh <- work{hasher, p, &h.writeWg}
	}
	h.writeWg.Wait()

	return len(p), nil
}

func finish(hashes []hash.Hash) map[string]string {
	result := make(map[string]string, len(hashes))
	for idx, hash := range hashes {
		result[names[idx]] = hex.EncodeToString(hash.Sum(nil))
	}

	return result
}
