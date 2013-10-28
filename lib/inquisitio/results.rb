module Inquisitio
  class Results < Array
    def initialize(items, current_page, results_per_page, total_count)
      super(items)
      @current_page     = current_page
      @results_per_page = results_per_page
      @total_count      = total_count
    end

    attr_reader :total_count, :results_per_page, :current_page
    alias_method :total_entries, :total_count
    alias_method :limit_value, :results_per_page

    def total_pages
      (total_count / results_per_page.to_f).ceil
    end
    alias_method :num_pages, :total_pages

    def last_page?
      current_page == total_pages
    end

    def to_a
      self
    end
  end
end
