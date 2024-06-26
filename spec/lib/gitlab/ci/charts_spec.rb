# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Charts, feature_category: :fleet_visibility do
  let_it_be(:project) { create(:project) }

  context 'yearchart' do
    let(:chart) { Gitlab::Ci::Charts::YearChart.new(project) }

    before_all do
      create(:ci_empty_pipeline, project: project, duration: 120)
    end

    it 'goes until the end of the current month (including the whole last day of the month)' do
      expect(chart.to).to eq(Date.today.end_of_month.end_of_day)
    end

    it 'starts at the beginning of the current year' do
      expect(chart.from).to eq(chart.to.years_ago(1).beginning_of_month.beginning_of_day)
    end

    it 'uses %B %Y as labels format' do
      expect(chart.labels).to include(chart.from.strftime('%B %Y'))
    end

    it 'returns count of pipelines run each day in the current year' do
      expect(chart.total.sum).to eq(1)
    end
  end

  context 'monthchart' do
    let(:chart) { Gitlab::Ci::Charts::MonthChart.new(project) }

    before_all do
      create(:ci_empty_pipeline, project: project, duration: 120)
    end

    it 'includes the whole current day' do
      expect(chart.to).to eq(Date.today.end_of_day)
    end

    it 'starts one month ago' do
      expect(chart.from).to eq(1.month.ago.beginning_of_day)
    end

    it 'uses %d %B as labels format' do
      expect(chart.labels).to include(chart.from.strftime('%d %B'))
    end

    it 'returns count of pipelines run each day in the current month' do
      expect(chart.total.sum).to eq(1)
    end
  end

  context 'weekchart' do
    let(:chart) { Gitlab::Ci::Charts::WeekChart.new(project) }

    before_all do
      create(:ci_empty_pipeline, project: project, duration: 120)
    end

    it 'includes the whole current day' do
      expect(chart.to).to eq(Date.today.end_of_day)
    end

    it 'starts one week ago' do
      expect(chart.from).to eq(1.week.ago.beginning_of_day)
    end

    it 'uses %d %B as labels format' do
      expect(chart.labels).to include(chart.from.strftime('%d %B'))
    end

    it 'returns count of pipelines run each day in the current week' do
      expect(chart.total.sum).to eq(1)
    end
  end

  context 'weekchart_utc' do
    let_it_be(:today) { Date.today }
    let_it_be(:end_of_today) do
      Time.use_zone(Time.find_zone('UTC')) { today.end_of_day }
    end

    let(:chart) { Gitlab::Ci::Charts::WeekChart.new(project) }

    before_all do
      # The created_at time used by the following execution
      # can end up being after the creation of the 'today' time
      # objects created above, and cause the queried counts to
      # go to zero when the test executes close to midnight on the
      # CI system, so we explicitly set it to a day earlier
      create(:ci_empty_pipeline, project: project, duration: 120, created_at: 1.day.before(today))
    end

    before do
      allow(Date).to receive(:today).and_return(today)
      allow(today).to receive(:end_of_day).and_return(end_of_today)
    end

    it 'uses a utc time zone for range times' do
      expect(chart.to.zone).to eq(end_of_today.zone)
      expect(chart.from.zone).to eq(end_of_today.zone)
    end

    it 'returns count of pipelines run each day in the current week' do
      expect(chart.total.sum).to eq(1)
    end
  end

  context 'weekchart_non_utc' do
    let_it_be(:today) { Date.today }
    let_it_be(:end_of_today) do
      Time.use_zone(Time.find_zone('Asia/Dubai')) { today.end_of_day }
    end

    let(:chart) { Gitlab::Ci::Charts::WeekChart.new(project) }

    subject { chart.total }

    before_all do
      # The DB uses UTC always, so our use of a Time Zone in the application
      # can cause the creation date of the pipeline to go unmatched depending
      # on the offset. We can work around this by requesting the pipeline be
      # created a with the `created_at` field set to a day ago in the same week.
      create(:ci_empty_pipeline, project: project, duration: 120, created_at: 1.day.before(today))
    end

    before do
      allow(Date).to receive(:today).and_return(today)
      allow(today).to receive(:end_of_day).and_return(end_of_today)
    end

    it 'uses a non-utc time zone for range times' do
      expect(chart.to.zone).to eq(end_of_today.zone)
      expect(chart.from.zone).to eq(end_of_today.zone)
    end

    it 'returns count of pipelines run each day in the current week' do
      expect(chart.total.sum).to eq(1)
    end
  end

  context 'pipeline_times' do
    let(:chart) { Gitlab::Ci::Charts::PipelineTime.new(project) }

    subject { chart.pipeline_times }

    before_all do
      create(:ci_empty_pipeline, project: project, duration: 120)
    end

    it 'returns pipeline times in minutes' do
      is_expected.to contain_exactly(2)
    end

    context 'when a pipeline has nil duration' do
      before_all do
        create(:ci_empty_pipeline, project: project, duration: nil)
      end

      it 'handles nil pipeline times' do
        is_expected.to contain_exactly(2, 0)
      end
    end
  end
end
