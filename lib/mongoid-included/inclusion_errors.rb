module Mongoid
  module DocumentInclusion
    class NotMongoidDocument < StandardError; end;
    class DocumentAlreadyIncluded < StandardError; end;
  end
end