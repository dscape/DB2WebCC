configure { Etags = {} }

helpers do
  def run_query query, db=""
    system "db2 connect to #{db}" unless db.empty?
    %x(db2 "#{query}").chomp.tap do
      system "db2 connect reset" unless db.empty?
    end
  end
  
  def render_view name
    eval "#{options.templating_engine} :#{name}"
  end
  
  def set_headers opts={}
    purge_cache if opts[:purge_cache]
    set_cache(opts[:cache]) unless opts[:cache].nil?
    content_type options.content_type_long, :charset => 'utf-8'
  end
  
  def set_cache opts={}
    max_age = opts[:max_age]
    etags = if opts[:etag].nil? then false else opts[:etag] end
    response.headers['Cache-Control'] = "max-age=#{max_age}" unless max_age.nil?
    etag(Etags[@env['PATH_INFO']] ||= Digest::SHA1.hexdigest(Time.now.to_s)) if etags
  end
  
  def purge_cache
    Etags[@env['PATH_INFO']] = nil
  end
end

# GET / => lists all databases
get "/" do
  set_headers :cache => {:max_age => 60, :etag => true}
  r      = /(Database alias)(\s+)?=(\s+)?(\w+)/
  @query = "list database directory"
  @dbs   = run_query(@query).split("\r\n").select { |s| r.match(s) }.map { |s| s.gsub(r,'\4') }
  render_view "list_dbs"
end

# POST / {:name => db-name}  => create a new database with name db-name
post "/" do
  unless params[:name].nil?
    set_headers :purge_cache => true
    @query = "create database #{params[:name]} using codeset utf-8 territory US"
    @result_set = run_query(@query)
    render_view "basic_response"
  end
end

# /:database/:table/:column/:xpath
get "/:db/:table/:column/*" do |db, table, column, xpath|
  set_headers :cache => {:max_age => 60}
  @db, @table, @column = db, table.upcase, column.upcase
  @xpath = if xpath.empty? then "" else ("/" + xpath).gsub("/", "/*:") end
  @query = "XQuery db2-fn:xmlcolumn('#{@table}.#{@column}')#{@xpath}"
  @result_set = run_query(@query, @db)
  render_view "xmlcolumn"
end