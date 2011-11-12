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
      `curl -L -o ./tmp/specs.tar.gz http://github.com/CocoaPods/Specs/tarball/master`
    end

    # Prepares the specs for indexing.
    #
    def prepare
      `rm -rf ./tmp/specs`
      `gunzip -f ./tmp/specs.tar.gz`
      `cd tmp; tar xvf specs.tar`
      `mv -f ./tmp/CocoaPods-Specs-* ./tmp/specs`
    end

  end

end