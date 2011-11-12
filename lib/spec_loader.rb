require 'net/http'

class CocoapodSearch

  class SpecLoader

    def get
      `wget http://github.com/CocoaPods/Specs/zipball/master -O specs.zip`
    end

    def prepare
      `unzip specs.zip -d specs`
      `mv specs/CocoaPods-Specs-*/* specs/`
      `rm -rf specs/CocoaPods-Specs-*`
    end

  end

end