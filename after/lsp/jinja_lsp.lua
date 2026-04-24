return {
	filetypes = { "jinja", "html.jinja" },
	root_markers = { "package.json", ".git" },
	settings = {
		template_extensions = { "njk", "html.jinja" },
		templates = "./src/pages",
		backend = { "./src" },
		lang = "python",
	},
}
