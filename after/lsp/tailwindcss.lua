return {
	filetypes = {
		'html.jinja',
		'jinja',
		-- defaults below
		'astro', 'blade', 'clojure',
		'htmldjango', 'eelixir', 'elixir',
		'eruby', 'haml', 'handlebars',
		'html', 'htmlangular', 'heex', 'liquid',
		'markdown', 'mustache', 'php', 'razor',
		'twig', 'css', 'less', 'sass', 'scss', 'stylus',
		'javascript', 'javascriptreact', 'rescript',
		'typescript', 'typescriptreact', 'vue', 'svelte', 'templ',
	},
	settings = {
		tailwindCSS = {
			includeLanguages = {
				htmldjango = "html",
				["html.jinja"] = "html",
				jinja = "html",
			}
		}
	}
}
