package multihash

import (
	"bytes"
	"fmt"
	"hash"
	"sync"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestMultihash(t *testing.T) {
	// head -c 1024 /dev/zero | sha1sum
	tests := []struct {
		size int
		sums map[string]string
	}{
		{
			1024,
			map[string]string{
				"md5":    "0f343b0931126a20f133d67c2b018a3b",
				"sha1":   "60cacbf3d72e1e7834203da608037b1bf83b40e8",
				"sha256": "5f70bf18a086007016e948b04aed3b82103a36bea41755b6cddfaf10ace3c6ef",
				"sha512": "8efb4f73c5655351c444eb109230c556d39e2c7624e9c11abc9e3fb4b9b9254218cc5085b454a9698d085cfa92198491f07a723be4574adc70617b73eb0b6461",
			},
		},
		{
			32 * 1024 * 1024,
			map[string]string{
				"md5":    "58f06dd588d8ffb3beb46ada6309436b",
				"sha1":   "57b587e1bf2d09335bdac6db18902d43dfe76449",
				"sha256": "83ee47245398adee79bd9c0a8bc57b821e92aba10f5f9ade8a5d1fae4d8c4302",
				"sha512": "1aeae269f4eb7c373e3b9af7cb8eece0ada42fcd1a74ac053fc505168f9caa568cf7ccb5622b7e8ab35fad44603797be4f44efe948a7cfa3ad0381f3f875e662",
			},
		},
	}

	for _, tc := range tests {
		t.Run(fmt.Sprintf("%d", tc.size), func(t *testing.T) {
			m := New()
			defer m.Close()

			_, err := m.Write(bytes.Repeat([]byte{0}, tc.size))
			require.NoError(t, err)

			sums := m.Hashes()
			for name, sum := range tc.sums {
				require.Equal(t, sum, sums[name])
			}
		})
	}
}

func TestMultihashClose(t *testing.T) {
	m := New()

	n, err := m.Write([]byte("foobar"))
	require.Equal(t, 6, n)
	require.NoError(t, err)
	require.NotEmpty(t, m.Hashes())

	m.Close()

	n, err = m.Write([]byte("foobar"))
	require.Equal(t, 0, n)
	require.Error(t, err)
	require.Empty(t, m.Hashes())

	m.Close()
	require.NotNil(t, New().h.buf)
}

func benchmarkHash(b *testing.B, h hash.Hash, chunk, writes int) {
	payload := bytes.Repeat([]byte("z"), chunk)

	b.SetBytes(int64(writes * len(payload)))
	b.ReportAllocs()
	b.ResetTimer()

	for n := 0; n < b.N; n++ {
		h.Reset()
		for i := 0; i < writes; i++ {
			_, _ = h.Write(payload)
		}

		h.Sum(nil)
	}
}

func sequentialMultiHash(payload []byte, writes int) {
	hashes := make([]hash.Hash, 0, len(factories))
	for _, newHash := range factories {
		hashes = append(hashes, newHash())
	}

	for _, h := range hashes {
		h.Reset()
		for i := 0; i < writes; i++ {
			_, _ = h.Write(payload)
		}
	}

	finish(hashes)
}

func benchmarkSequentialMultihash(b *testing.B, chunk, writes int) {
	payload := bytes.Repeat([]byte("z"), chunk)

	b.SetBytes(int64(writes * len(payload)))
	b.ReportAllocs()
	b.ResetTimer()

	for n := 0; n < b.N; n++ {
		sequentialMultiHash(payload, writes)
	}
}

func concurrentMultiHash(payload []byte, writes int) {
	m := New()

	for i := 0; i < writes; i++ {
		_, _ = m.Write(payload)
	}

	m.Hashes()
	m.Close()
}

func benchmarkMultihash(b *testing.B, chunk, writes int) {
	payload := bytes.Repeat([]byte("z"), chunk)

	b.SetBytes(int64(writes * len(payload)))
	b.ReportAllocs()
	b.ResetTimer()

	for n := 0; n < b.N; n++ {
		concurrentMultiHash(payload, writes)
	}
}

func BenchmarkHashes(b *testing.B) {
	tests := []struct {
		name   string
		chunk  int
		writes int
	}{
		{"8B-x1", 8, 1},
		{"8B-x1024", 8, 1024},
		{"8KiB-x1", 8 * 1024, 1},
		{"8KiB-x1024", 8 * 1024, 1024},

		{"64B-x1", 64, 1},
		{"64B-x1024", 64, 1024},
		{"64KiB-x1", 64 * 1024, 1},
		{"64KiB-x1024", 64 * 1024, 1024},
	}

	for idx, newHash := range factories {
		b.Run("64B-x1024-"+names[idx], func(b *testing.B) {
			benchmarkHash(b, newHash(), 64*1024, 1024)
		})
	}

	for _, tc := range tests {
		b.Run(tc.name+"-multi-sequential", func(b *testing.B) {
			benchmarkSequentialMultihash(b, tc.chunk, tc.writes)
		})

		b.Run(tc.name+"-multi-concurrent", func(b *testing.B) {
			benchmarkMultihash(b, tc.chunk, tc.writes)
		})
	}
}

func BenchmarkMultiHashesNoiseyNeighbours(b *testing.B) {
	payload := bytes.Repeat([]byte("z"), 64*1024)
	neighbours := 32

	b.Run("64KiB-x1024-multi-sequential", func(b *testing.B) {
		b.SetBytes(int64(1024 * len(payload)))
		b.ReportAllocs()
		b.ResetTimer()

		for n := 0; n < b.N; n++ {
			var wg sync.WaitGroup
			wg.Add(neighbours)
			for i := 0; i < neighbours; i++ {
				go func() {
					sequentialMultiHash(payload, 1024)
					wg.Done()
				}()
			}
			wg.Wait()
		}
	})

	b.Run("64KiB-x1024-multi-concurrent", func(b *testing.B) {
		b.SetBytes(int64(1024 * len(payload)))
		b.ReportAllocs()
		b.ResetTimer()

		for n := 0; n < b.N; n++ {
			var wg sync.WaitGroup
			wg.Add(neighbours)
			for i := 0; i < neighbours; i++ {
				go func() {
					concurrentMultiHash(payload, 1024)
					wg.Done()
				}()
			}
			wg.Wait()
		}
	})
}
