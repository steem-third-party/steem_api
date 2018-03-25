module SteemApi
  module Vo
    class CommentBenefactorReward < SteemApi::SqlBase

      self.table_name = :VOCommentBenefactorRewards

    end
  end
end

# Structure
#
# SteemApi::Vo::CommentBenefactorReward(
#   ID: integer,
#   block_num: integer,
#   timestamp: datetime,
#   benefactor: varchar,
#   author: varchar,
#   permlink: varchar,
#   reward: varchar
# )
