require "test_helper"
require "test_fakes"

class DeepStackTest < ActiveModel::TestCase

  class List
    include ActiveModel::SerializerSupport

    attr_accessor :id, :targets
    def active_model_serializer; ListSerializer; end

    def initialize(id)
      @id = id
    end
  end

  class Target
    include ActiveModel::SerializerSupport
    attr_accessor :id, :lists
    def active_model_serializer; TargetSerializer; end

    def initialize(id)
      @id = id
    end
  end

  class ListSerializer < ActiveModel::Serializer
  end
  class TargetSerializer < ActiveModel::Serializer
  end

  def test_embed_ids_include_true
    ListSerializer.has_many :targets, :embed => :ids, :include => true
    TargetSerializer.has_many :lists, :embed => :ids, :include => true

    list = List.new(1)
    target = Target.new(2)

    list.targets = [target]
    target.lists = [list]

    json = target.active_model_serializer.new(target).as_json

    assert_equal({
      :target=>{:list_ids=>[1]},
      :lists=>[{:target_ids=>[2]}],
      :targets=>[{:list_ids=>[1]}]
    }, json)
  end

  def test_default_circular_nesting
    ListSerializer.has_many :targets
    TargetSerializer.has_many :lists

    list = List.new(1)
    target = Target.new(2)

    list.targets = [target]
    target.lists = [list]

    assert_nothing_raised do
      target.active_model_serializer.new(target).as_json
    end
  end
end


