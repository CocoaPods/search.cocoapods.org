require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../../../../lib/models/pod', __FILE__)

describe Pod do

  # TODO Rewrite.
  #
  # describe '#specification_json' do
  #   before do
  #     @pod = Domain.pods.insert(:name => 'TestPod1')
  #     version = @pod.add_version(:name => '1.10.0')
  #     version.add_commit(:sha => 'shalalalala', :committer_id => 1, :specification_data => 'data10')
  #     version = @pod.add_version(:name => '1.9.0')
  #     version.add_commit(:sha => 'shalalalala', :committer_id => 1, :specification_data => 'data9')
  #   end
  #   it 'returns the data of the last version' do
  #     @pod.specification_json.should == 'data10'
  #   end
  # end

end
