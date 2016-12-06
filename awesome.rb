require 'mechanize'

$data_list = []

def scrape_github link , n_pages
    agent = Mechanize.new
    page = agent.get(link)
    limit = page.search(".pagination a").count
    tot = 0
    total_pages = page.search(".pagination a")[limit-2].text.to_i
    n_pages = (total_pages < n_pages) ? total_pages : n_pages
    for i in (1..n_pages)
        link = link + "&p=#{i}"
        page = agent.get(link)
        page.search(".repo-list li").each do |p|
            if ((p.search("p").text.strip.scan(/list/).count < 2 && p.search("p").text.strip.scan(/awesome/).count < 2) || (p.search("p").text.strip.include? "inspire"))
                tot = tot+1
                data = {}
                data["link"] = "https://github.com"+p.search("a").first["href"]
                data["desc"] = p.search("p").text.strip
                data["repo"] = p.search(".d-inline-block").text.strip
                $data_list.push(data)
            end    
        end    
    end    

end

def create_readme filename , template

end

scrape_github("https://github.com/search?utf8=✓&q=awesome+curated+list",4)
# create_readme("README.md" , "README_template.erb")
