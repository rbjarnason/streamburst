class Torrent < ActiveRecord::Base
  has_and_belongs_to_many :products

  def get_passkey_torrent(user)
    @torrent_user = TorrentUser.find(user.torrent_user_id)
    unless @torrent_user
      logger.error("Can't find user in GetTorrent")
      raise "cant find user"
      return
    end
    return self.torrent_data.gsub(/%sub1/, @torrent_user.passkey), self.file_name
  end

end
