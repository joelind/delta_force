require 'helper'

class TestActiveRecordIntegration < Test::Unit::TestCase
  context 'tracks_changes_over_time' do
    setup do
      Foo.tracks_changes_over_time do |changes|
        changes.values :x, :y, :z, :over => :period, :by => :bar_id
      end
    end

    should 'add a changes_in_* named scope' do
      assert Foo.respond_to?(:changes_in_x_and_y_and_z_by_bar_id_over_period)
    end

    context 'with foos for a given bar' do
      setup do
        @bar = Factory(:bar)
        @foos = 3.times.collect do |i|
          Factory :foo, :bar => @bar, :period => (i+1).days.from_now.to_date,
            :x => (i+1), :y => (i+1) * 10, :z => (i+1) * 100
        end

        #decoy foo
        Factory :foo
      end

      context 'bar.foos.x_by_bar_id_as_of_period' do
        should 'have the correct x' do
          @foos.each do |foo|
            result = @bar.foos.x_by_bar_id_as_of_period(foo.period)
            assert_equal foo.x, result[@bar.id]
          end
        end
      end

      context 'bar.foos.changes_in_x_and_y_and_z_by_bar_id_over_period' do
        subject { @bar.foos.changes_in_x_and_y_and_z_by_bar_id_over_period }

        should 'return a scope containig one object' do
          assert_equal 1, subject.all.size
        end

        should 'return an object with opening_period' do
          assert_equal @foos.first.period, subject.first.opening_period.to_date
        end

        should 'return an object with closing_period' do
          assert_equal @foos.last.period, subject.first.closing_period.to_date
        end

        should 'return an object with closing_x' do
          assert_equal @foos.last.x, subject.first.closing_x.to_f
        end

        should 'return an object with opening_x' do
          assert_equal @foos.first.x, subject.first.opening_x.to_f
        end

        should 'return an object with closing_y' do
          assert_equal @foos.last.y, subject.first.closing_y.to_f
        end

        should 'return an object with opening_y' do
          assert_equal @foos.first.y, subject.first.opening_y.to_f
        end

        should 'return an object with closing_z' do
          assert_equal @foos.last.z, subject.first.closing_z.to_f
        end

        should 'return an object with opening_z' do
          assert_equal @foos.first.z, subject.first.opening_z.to_f
        end
      end
    end
  end
end
