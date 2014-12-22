require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../../../../lib/models/pod', __FILE__)

describe Pod do

  describe 'AFNetworking' do

    def pod
      Pod.all { |pods| pods.where(name: 'AFNetworking') }.first
    end

    ok { pod.name.should == 'AFNetworking' }
    ok { pod.mapped_name.should == 'afnetworking af networking' }
    ok { pod.split_name.should == %w(afnetworking af networking) }
    ok { pod.split_name_for_automatic_splitting.should == ['networking'] }

    ok { pod.authors.should == { 'Mattt Thompson' => 'm@mattt.me' } }
    ok { pod.mapped_authors.should == 'Mattt Thompson' }

    ok { pod.platforms.should == %w(ios osx) }
    ok { pod.mapped_platform.should == 'ios osx' }

    ok { pod.dependencies.should == [] }

    ok { pod.summary.should == 'A delightful iOS and OS X networking framework.' }

    # This is just a rough sanity check.
    ok { pod.popularity.should >= 70_000 }
    ok { pod.forks.should >= 3400 }
    ok { pod.contributors.should >= 30 }
    ok { pod.subscribers.should >= 1000 }

  end

  describe 'KGDiscreetAlertView' do

    def pod
      Pod.all { |pods| pods.where(name: 'KGDiscreetAlertView') }.first
    end

    ok { pod.platforms.should == %w(ios) }
    ok { pod.mapped_platform.should == 'ios' }

  end
  
  describe 'CCLDefaults' do

    def pod
      Pod.all { |pods| pods.where(name: 'CCLDefaults') }.first
    end

    ok { pod.mapped_authors.should == 'Kyle Fuller' }

  end
  
  describe 'QueryKit' do

    def pod
      Pod.all { |pods| pods.where(name: 'QueryKit') }.first
    end

    ok { pod.mapped_authors.should == 'Kyle Fuller' }

  end

end
