package bump

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestGetFilePath(t *testing.T) {
	assert := assert.New(t)

	assert.Equal("/version/.version", getFilePath("/version", ".version"))
}
