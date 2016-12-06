require 'mechanize'
require 'erb'

$data_list = []

def scrape_github link , n_pages
    agent = Mechanize.new
    page = agent.get(link)
    limit = page.search(".pagination a").count
    tot = 0
    total_pages = page.search(".pagination a")[limit-2].text.to_i
    n_pages = (n_pages == -1) ? total_pages : ((total_pages < n_pages) ? total_pages : n_pages)
    for i in (1..n_pages)
        #Important to use sleep, to avoid time-out of requests from github
        sleep 10
        link = link + "&p=#{i}"
        page = agent.get(link)
        page.search(".repo-list li").each do |p|
            if ((p.search("p").text.strip.scan(/list/).count < 2 && p.search("p").text.strip.scan(/awesome/).count < 2) || (p.search("p").text.strip.include? "inspire"))
                # Leave out other lists of awesome lists
                tot = tot+1
                data = {}
                data["link"] = "https://github.com"+p.search("a").first["href"]
                data["desc"] = p.search("p").text.strip
                data["repo"] = p.search(".d-inline-block").text.strip
                $data_list.push(data)
                puts "\n Added (#{tot}) #{data["repo"]} - #{data["desc"]}."

            end    
        end    
    end    
end

def create_readme filename , template
    puts "\n Reading README.md template."
    readme_text = (File.exists? template) ? ERB.new(File.open(template).read, 0, '>').result(binding) : ""
    File.open(filename, "w") { |file| file.write(readme_text) }
    puts "\n Generated README.md from template."
end

scrape_github("https://github.com/search?utf8=✓&q=awesome+curated+list",15)
create_readme("README.md" , "README_template.erb")
