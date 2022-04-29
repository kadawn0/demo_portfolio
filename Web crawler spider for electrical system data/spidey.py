import scrapy
from scrapy.crawler import CrawlerProcess
import os
import requests

dir = os.path.dirname(os.path.abspath(__file__)) + "\\Archivos SINC"
links_descarga = []


class Spidey(scrapy.Spider):
    name = "Spidey"
    start_urls = ['https://www.coordinadorelectrico.cl/sistema-informacion-publica/']
    custom_settings = {"ITEM_PIPELINES": {'scrapy.pipelines.files.FilesPipeline': 1}, "FILES_STORE": dir, }

    def parse(self, response):
        print(links_descarga)
        SET_SELECTOR = '.cont-tabla' # página inicial
        for tabla in response.css(SET_SELECTOR):
            print("START")
            NAME_SELECTOR = '.tabla table tr td a ::attr(href)'
            ext = tabla.css(NAME_SELECTOR).extract() # extrae los links
            for link in ext:
                if link != "#":
                    print(link)
                    if ".zip" in link or "download" in link or "baja" in link or "archivo" in link or ".7zip" in link or ".rar" in link \
                            or ".pdf" in link or "file" in link \
                            or ".pdf" in link or ".xls" in link or ".xlsx" in link:
                        links_descarga.append(link)
                    else:
                        yield scrapy.Request(
                            response.urljoin(link),
                            callback=self.parse_sig
                        )

    def parse_sig(self, response):
        print(links_descarga)
        alt_NAME_SELECTOR = ".col-sm-12"  # páginas del tipo de las auditorías del norte grande
        a_alt_NAME_SELECTOR = ".multilist-column"  # página de acceso a fichas técnicas
        for a in response.css(alt_NAME_SELECTOR):
            ext = a.css(alt_NAME_SELECTOR + " div h3 a ::attr(href)").extract()
            print("SECOND")
            for link in ext:
                if link != "#":
                    print(link)
                    if ".zip" in link or "download" in link or "baja" in link or "archivo" in link or ".7zip" in link or ".rar" in link \
                            or ".pdf" in link or "file" in link \
                            or ".pdf" in link or ".xls" in link or ".xlsx" in link:
                        links_descarga.append(link)
                    elif ".pfd" in link:
                        continue
                    else:
                        yield scrapy.Request(
                            response.urljoin(link),
                            callback=self.parse_sig
                        )
        for a in response.css(alt_NAME_SELECTOR):
            ext = a.css(alt_NAME_SELECTOR + " div div a ::attr(href)").extract()
            print("SECOND ALT (PDFS)")
            for link in ext:
                if link != "#":
                    print(link)
                    if ".zip" in link or "download" in link or "baja" in link or "archivo" in link or ".7zip" in link or ".rar" in link \
                            or ".pdf" in link or "file" in link \
                            or ".pdf" in link or ".xls" in link or ".xlsx" in link:
                        links_descarga.append(link)
                    elif ".pfd" in link:
                        continue
                    else:
                        yield scrapy.Request(
                            response.urljoin(link),
                            callback=self.parse_sig
                        )
        print(response.css(a_alt_NAME_SELECTOR))
        for a in response.css(a_alt_NAME_SELECTOR):
            ext = a.css(alt_NAME_SELECTOR + " ul li a ::attr(href)").extract()
            print("THIRD")
            for link in ext:
                if link != "#":
                    print(link)
                    if ".zip" in link or "download" in link or "baja" in link or "archivo" in link or ".7zip" in link or ".rar" in link \
                            or ".pdf" in link or "file" in link \
                            or ".pdf" in link or ".xls" in link or ".xlsx" in link:
                        links_descarga.append(link)
                    elif ".pfd" in link:
                        continue
                    else:
                        yield scrapy.Request(
                            response.urljoin(link),
                            callback=self.parse_sig
                        )

    def closed(self, reason):
        global links_descarga
        print("DOWNLOADING")
        input("OK!")
        print(links_descarga)
        for link in links_descarga:
            name = str(link)
            if "http:" not in name:
                if "zip" not in name:
                    name = "http://cdec2.cdec-sing.cl" + name
                else:
                    name = "http://sic.coordinadorelectrico.cl" + str(link)
            try:
                r = requests.get(name, stream=True)
            except:
                name = "http://sic.coordinadorelectrico.cl" + str(link)
                r = requests.get(name, stream=True)
            with open(name, 'wb') as f:
                for chunk in r.iter_content():
                    f.write(chunk)

process = CrawlerProcess({
    'USER_AGENT': 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)'
})

process.crawl(Spidey)
process.start() # the script will block here until the crawling is finished