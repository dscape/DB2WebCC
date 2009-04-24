cache = {} 
# /
get "/" do
  r = /(Database alias)(\s+)?=(\s+)?(\w+)/
  @query = "list database directory"
  @dbs ||= %x(db2 #{@query}).split("\r\n").select { |s| r.match(s) }.map { |s| s.gsub(r,'\4') }
  erb :list_databases
end

post "/" do
end

# /:database/:table/:column/:xpath
get "/:db/:table/:column/*" do |db, table, column, xpath|
  @db, @table, @column = db, table.upcase, column.upcase
  @xpath = if xpath.empty? then "" else ("/" + xpath).gsub("/", "/*:") end
  content_type 'application/xml', :charset => 'utf-8'
  @query = "XQuery db2-fn:xmlcolumn('#{@table}.#{@column}')#{@xpath}"
  system "db2 connect to #{@db}"
  @result_set = cache[@query] ||= %x(db2 #{@query})
  system "db2 connect reset"
  erb :xmlcolumn_xpath
end