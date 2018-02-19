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
activate :directory_indexes

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

helpers do
  #
  # returns the correct path in the current locale
  # @example
  # = link_to "bar", url("foo/bar.html")
  #
  def path(url, options = {})
    puts "&&&&&&#{options[:lang]}"
    lang = options[:lang] || I18n.locale.to_s
    if lang.to_s == 'en'
      prefix = ''
    else

      prefix = "/#{lang}"
    end
    
    rUrl = prefix + "/" + clean_from_i18n(url)
    puts "%%%%%%%#{url}"
    puts "%%%%%%%#{rUrl}"
    puts "%%%%%%%#{clean_from_i18n(url)}"
    return rUrl
    
  end

  # removes an i18n lang code from url if its present
  def clean_from_i18n(url)
    parts = url.split('/').select { |p| p && p.size > 0 }
    parts.shift if langs.map(&:to_s).include?(parts[0])
    parts.join('/')
  end

  def root_url() 
    return ""
  end
end

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
  puts "#"*100
  localeID = file.split('.')[0].split('/')[1].to_sym
  yaml = transform_keys_to_symbols(YAML.load_file(file))[localeID]
  yaml[:campaings].each do |item|
    if item[:has_detail]
      page = "#{localeID == :en ? '' :'/'+localeID.to_s}/campaings/#{item[:title]}.html"
      puts "creating #{page}"
      proxy page, "/campaings/template.html", :locals => { :title => item[:title], :item => item }, locale: localeID, :ignore => true
    end
  end

  yaml[:games_all].each do |item|
    if item[:has_detail]
      page = "#{localeID == :en ? '' :'/'+localeID.to_s}/games/#{item[:title]}.html"
      puts "creating #{page}"
      proxy page, "/games/detail#{item[:template]}.html", :locals => { :title => item[:title], :item => item }, locale: localeID, :ignore => true
    end
  end
end

# r().each do |item|
#     proxy "/campaings/#{item[:title]}.html", "/about/template.html", :locals => { :item => item }
# end

configure :build do
  set :http_prefix, subPage
  activate :asset_host, :host => 'https://www.timokids.com.br/#{subPage}'
  activate :minify_css
  activate :minify_javascript
end