package utils

import (
	"encoding/base64"
	"fmt"
	"strings"
	"time"
)

// EncodeCursor creates a base64 encoded cursor string
func EncodeCursor(t time.Time, uuid string) string {
	// Combine timestamp and uuid with a separator, then Base64 encode
	raw := fmt.Sprintf("%s|%s", t.Format(time.RFC3339Nano), uuid)
	return base64.StdEncoding.EncodeToString([]byte(raw))
}

// DecodeCursor parses a base64 encoded cursor string
func DecodeCursor(c string) (time.Time, string) {
	b, err := base64.StdEncoding.DecodeString(c)
	if err != nil {
		return time.Time{}, ""
	}

	parts := strings.Split(string(b), "|")
	if len(parts) != 2 {
		return time.Time{}, ""
	}

	t, err := time.Parse(time.RFC3339Nano, parts[0])
	if err != nil {
		return time.Time{}, ""
	}

	return t, parts[1]
}
