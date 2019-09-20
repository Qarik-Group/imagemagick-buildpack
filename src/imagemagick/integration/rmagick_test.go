package integration_test

import (
	"path/filepath"

	"github.com/cloudfoundry/libbuildpack/cutlass"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("Ruby/RMagick App Integration Test", func() {
	var app *cutlass.App
	AfterEach(func() {
		if app != nil {
			app.Destroy()
		}
		app = nil
	})

	It("app deploys", func() {
		app = cutlass.New(filepath.Join(bpDir, "fixtures", "rubyapp-rmagick"))
		app.Buildpacks = []string{"imagemagick_buildpack", "ruby_buildpack"}
		PushAppAndConfirm(app)
		Expect(app.GetBody("/")).To(ContainSubstring("rmagick RMagick 4.1.0.rc2 app using ImageMagick7"))
	})
})
