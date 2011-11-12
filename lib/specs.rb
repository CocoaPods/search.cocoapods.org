require 'net/http'

class CocoapodSearch

  class Specs

    # Are there any specs to index?
    #
    def empty?
      Dir['./tmp/specs/*'].empty?
    end

    # Gets the latest master specs from the Specs repo.
    #
    # Note: Overwrites the old specs.zip.
    #
    def get
      `curl -L -o ./tmp/specs.zip http://github.com/CocoaPods/Specs/zipball/master`
    end

    # Prepares the specs for indexing.
    #
    def prepare
      `rm -rf ./tmp/specs`
      `unzip ./tmp/specs.zip -d ./tmp/specs`
      `mv -f ./tmp/specs/CocoaPods-Specs-*/* ./tmp/specs/`
      `rm -rf ./tmp/specs/CocoaPods-Specs-*`
    end

  end

end