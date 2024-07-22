require "fileutils"
require "net/http"
require "plist"
require "tmpdir"
require "zip"

class LocoUpdater
  attr_accessor :base_path, :credentials_plist, :app_plist, :info_plist, :loco_key

  def initialize(base_path)
    self.base_path = base_path
    self.credentials_plist = Plist.parse_xml("#{self.base_path}/Others/Credentials.plist")
    self.app_plist = Plist.parse_xml("#{self.base_path}/Others/App.plist")
    self.info_plist = Plist.parse_xml("#{self.base_path}/Main/Info.plist")
    self.loco_key = self.credentials_plist["loco"]["key"]
  end

  def fetch_bundle(tmpdir)
    puts "  - fetching bundle into #{tmpdir}"
      
    Net::HTTP.start("localise.biz", :use_ssl => true) { |http|
      request = Net::HTTP::Get.new "/api/export/archive/strings.zip?filter=!InfoPlist"
      request.basic_auth self.loco_key, ""
      response = http.request request
      
      zipped_bundle = response.body
      File.open("#{tmpdir}/bundle.zip", "w") { |file| file.write(zipped_bundle) }
      Dir.mkdir("#{tmpdir}/Localizable.bundle")
      Zip::File.open("#{tmpdir}/bundle.zip") { |zipfile|
        zipfile.each { |file|
          match = file.name.match /.*\/([a-zA-Z\-]+\.lproj)\/Localizable\.strings/
          if match
            Dir.mkdir("#{tmpdir}/Localizable.bundle/#{match[1][0...2]}.lproj")
            zipfile.extract(file, "#{tmpdir}/Localizable.bundle/#{match[1][0...2]}.lproj/Localizable.strings")
          end
        }
      }
    }
    FileUtils.rm_rf("#{self.base_path}/Others/Localizable.bundle")
    FileUtils.mv("#{tmpdir}/Localizable.bundle", "#{self.base_path}/Others/Localizable.bundle")
  end

  def fetch_infoplist(tmpdir)
    puts "  - fetching InfoPlist.strings into #{tmpdir}"
    system("rm -Rf #{self.base_path}/Others/*.lproj")
    Net::HTTP.start("localise.biz", :use_ssl => true) { |http|
      request = Net::HTTP::Get.new "/api/export/archive/strings.zip?filter=InfoPlist"
      request.basic_auth self.loco_key, ""
      response = http.request request
      
      zipped_bundle = response.body
      File.open("#{tmpdir}/bundle.zip", "w") { |file| file.write(zipped_bundle) }
      Dir.mkdir("#{tmpdir}/InfoPlist")
      Zip::File.open("#{tmpdir}/bundle.zip") { |zipfile|
        zipfile.each { |file|
          match = file.name.match /.*\/([a-zA-Z\-]+\.lproj)\/Localizable\.strings/
          if match
            Dir.mkdir("#{tmpdir}/InfoPlist/#{match[1][0...2]}.lproj")
            zipfile.extract(file, "#{tmpdir}/InfoPlist/#{match[1][0...2]}.lproj/InfoPlist.strings")
            FileUtils.mv("#{tmpdir}/InfoPlist/#{match[1][0...2]}.lproj", "#{self.base_path}/Others/#{match[1][0...2]}.lproj")
          end
        }
      }
    }
  end

  def update
    puts "Updating loco..."
    Dir.mktmpdir { |dir| 
      fetch_bundle(dir)
    }
    if credentials_plist["loco"]["should_override_info_plist"]
      Dir.mktmpdir { |dir|
        fetch_infoplist(dir)
      }
    else
      puts "  - NOTE: skipping InfoPlist.strings due to Credentials.plist setting"
    end
  end
end