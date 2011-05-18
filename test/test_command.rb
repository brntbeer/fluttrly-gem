require 'test/unit'
require 'rubygems'
require 'fluttrly-gem'
require 'net/http'
require 'JSON'

class TestCommand < Test::Unit::TestCase
  
  def setup
    @list = Fluttrly::Command.list("bouverdafs")
    @finished = @list.select{|item| item["task"]["completed"] == true }
  end

  def test_list_size_increases_after_post
    Fluttrly::Command.post("bouverdafs", "8=======D~~~~")
    new_size = Fluttrly::Command.list("bouverdafs").size
    assert (new_size > @list.size)
  end

  def test_list_update_includes_newly_completed_item
    Fluttrly::Command.update("bouverdafs", 1)
    list = Fluttrly::Command.list("bouverdafs")
    finished = list.select{|item| item["task"]["completed"] == true}
    assert list.include?(finished.first)
  end

  def test_size_decreases_after_delete
    #offset the item to be deleted due to code looking at num-1
    Fluttrly::Command.delete("bouverdafs", (@list.size-@finished.size)+1)
    new_size = Fluttrly::Command.list("bouverdafs").size
    assert (new_size < @list.size)
  end

end
