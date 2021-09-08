# frozen_string_literal: true

module Boards
  class EpicBoardPresenter < Gitlab::View::Presenter::Delegated
    presents :epic_board, ::Boards::EpicBoard
  end
end
