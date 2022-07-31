package headers

import (
	"net/http"
	"regexp"

	"gitlab.com/gitlab-org/gitlab/workhorse/internal/utils/svg"
)

var (
	javaScriptTypeRegex = regexp.MustCompile(`^(text|application)\/javascript$`)

	imageTypeRegex   = regexp.MustCompile(`^image/*`)
	svgMimeTypeRegex = regexp.MustCompile(`^image/svg\+xml$`)

	textTypeRegex = regexp.MustCompile(`^text/*`)

	videoTypeRegex = regexp.MustCompile(`^video/*`)

	pdfTypeRegex = regexp.MustCompile(`application\/pdf`)

	attachmentRegex = regexp.MustCompile(`^attachment`)
	inlineRegex     = regexp.MustCompile(`^inline`)

	applicationTypeRegex = regexp.MustCompile(`^application/.*`)
	octetStreamRegex     = regexp.MustCompile(`^application/octet-stream$`)
)

// Mime types that can't be inlined. Usually subtypes of main types
var forbiddenInlineTypes = []*regexp.Regexp{svgMimeTypeRegex}

// Mime types that can be inlined. We can add global types like "image/" or
// specific types like "text/plain". If there is a specific type inside a global
// allowed type that can't be inlined we must add it to the forbiddenInlineTypes var.
// One example of this is the mime type "image". We allow all images to be
// inlined except for SVGs.
var allowedInlineTypes = []*regexp.Regexp{imageTypeRegex, textTypeRegex, videoTypeRegex, pdfTypeRegex}

const (
	svgContentType            = "image/svg+xml"
	textPlainContentType      = "text/plain; charset=utf-8"
	attachmentDispositionText = "attachment"
	inlineDispositionText     = "inline"
)

func SafeContentHeaders(filenameContentType string, data []byte, contentDisposition string) (string, string) {
	contentType := safeContentType(data)
	contentDisposition = safeContentDisposition(contentType, contentDisposition)

	contentType = attachmentContentType(contentDisposition, contentType, filenameContentType)

	return contentType, contentDisposition
}

func safeContentType(data []byte) string {
	// Special case for svg because DetectContentType detects it as text
	if svg.Is(data) {
		return svgContentType
	}

	// Override any existing Content-Type header from other ResponseWriters
	contentType := http.DetectContentType(data)

	// http.DetectContentType does not support JavaScript and would only
	// return text/plain. But for cautionary measures, just in case they start supporting
	// it down the road and start returning application/javascript, we want to handle it now
	// to avoid regressions.
	if isType(contentType, javaScriptTypeRegex) {
		return textPlainContentType
	}

	// If the content is text type, we set to plain, because we don't
	// want to render it inline if they're html or javascript
	if isType(contentType, textTypeRegex) {
		return textPlainContentType
	}

	return contentType
}

func safeContentDisposition(contentType string, contentDisposition string) string {
	// If the existing disposition is attachment we return that. This allow us
	// to force a download from GitLab (ie: RawController)
	if attachmentRegex.MatchString(contentDisposition) {
		return contentDisposition
	}

	// Checks for mime types that are forbidden to be inline
	for _, element := range forbiddenInlineTypes {
		if isType(contentType, element) {
			return attachmentDisposition(contentDisposition)
		}
	}

	// Checks for mime types allowed to be inline
	for _, element := range allowedInlineTypes {
		if isType(contentType, element) {
			return inlineDisposition(contentDisposition)
		}
	}

	// Anything else is set to attachment
	return attachmentDisposition(contentDisposition)
}

func attachmentContentType(contentDisposition string, contentType string, filenameContentType string) string {
	// If the final Content-Disposition is an attachment based on the
	// scanned Content-Type, the Content-Type should not matter to the
	// browser. The filename extension would likely be more accurate
	// for application formats, such as application/zip (.docx, .odpb, .odt, etc.).
	//
	// In the future we may want to allow for specific subtypes as the Marcel
	// gem does: https://github.com/rails/marcel/blob/fc69a19d17de4fedca354b2404b04834b16eacd8/lib/marcel/mime_type.rb#L77-L86
	if attachmentRegex.MatchString(contentDisposition) &&
		isType(filenameContentType, applicationTypeRegex) &&
		!isType(filenameContentType, octetStreamRegex) &&
		isType(contentType, applicationTypeRegex) {
		return filenameContentType
	}

	return contentType
}

func attachmentDisposition(contentDisposition string) string {
	if contentDisposition == "" {
		return attachmentDispositionText
	}

	if inlineRegex.MatchString(contentDisposition) {
		return inlineRegex.ReplaceAllString(contentDisposition, attachmentDispositionText)
	}

	return contentDisposition
}

func inlineDisposition(contentDisposition string) string {
	if contentDisposition == "" {
		return inlineDispositionText
	}

	if attachmentRegex.MatchString(contentDisposition) {
		return attachmentRegex.ReplaceAllString(contentDisposition, inlineDispositionText)
	}

	return contentDisposition
}

func isType(contentType string, mimeType *regexp.Regexp) bool {
	return mimeType.MatchString(contentType)
}
