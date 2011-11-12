require 'net/http'

class CocoapodSearch

  class Specs

    # Gets the latest master specs from the Specs repo.
    #
    # Note: Overwrites the old specs.zip.
    #
    def get
      `wget http://github.com/CocoaPods/Specs/zipball/master -O specs.zip`
    end

    # Prepares the specs for indexing.
    #
    def prepare
      `rm -rf specs`
      `unzip specs.zip -d specs`
      `mv -f specs/CocoaPods-Specs-*/* specs/`
      `rm -rf specs/CocoaPods-Specs-*`
    end

  end

end