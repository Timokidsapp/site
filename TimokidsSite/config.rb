# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

activate :i18n

# With alternative layout
# page '/path/to/file.html', layout: 'other_layout'

# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/

# proxy(
#   '/this-page-has-no-template.html',
#   '/template-file.html',
#   locals: {
#     which_fake_page: 'Rendering a fake page with a local variable'
#   },
# )

# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/

# helpers do
#   def some_helper
#     'Helping'
#   end
# end

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

def self.transform_keys_to_symbols(value)
  if value.kind_of?(::Hash)
    hash = value.inject({}){|memo,(k,v)| memo[k.to_sym] = transform_keys_to_symbols(v); memo}
    return hash
  elsif value.kind_of?(::Array)
    return value.map { |a| transform_keys_to_symbols(a) }
  end
  
  return value
  
end

Dir.glob('locales/*').each do |file|
  
  localeID = file.split('.')[0].split('/')[1].to_sym
  yaml = transform_keys_to_symbols(YAML.load_file(file))[localeID]

  yaml[:campanhas].each do |item|
    puts "*"*100
    puts item["campanha1_title"]
    proxy "#{localeID == :en ? '' :'/'+localeID.to_s}/campanhas/#{item[:campanha1_title]}.html", "/campaings/template.html", :locals => { :item => item }, locale: localeID, :ignore => true
  end
end

# r().each do |item|
#     proxy "/campanhas/#{item[:campanha1_title]}.html", "/about/template.html", :locals => { :item => item }
# end

configure :build do
  set :http_prefix, "/novosite"
  activate :asset_host, :host => 'https://www.timokids.com.br/novosite/'
  activate :minify_css
  activate :minify_javascript
end

