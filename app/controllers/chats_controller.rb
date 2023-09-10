class ChatsController < ApplicationController
  before_action :reject_non_related, only: [:show]
  
  def show
     #BさんのUser情報を取得
   @user = User.find(params[:id])
  #user_roomsテーブルのuser_idがAさんのレコードのroom_idを配列で取得
   rooms = current_user.user_rooms.pluck(:room_id)
  #user_idがBさん(@user)で、room_idがAさんの属するroom_id（配列）となるuser_roomsテーブルのレコードを取得して、user_room変数に格納
  #これによって、AさんとBさんに共通のroom_idが存在していれば、その共通のroom_idとBさんのuser_idがuser_room変数に格納される（1レコード）。存在しなければ、nilになる。
   user_room = UserRoom.find_by(user_id: @user.id, room_id: rooms)
   
   unless user_room.nil?
     @room = user_rooms.room
   else
     @room = Room.new
     @room.save
     UserRoom.create(user_id: current_user.id, room_id: @room.id)
     UserRoom.create(user_id: @user.id, room_id: @room.id)
   end
    @chats = @room.chats
    @chat = Chat.new(room_id: @room.id)
  end
  
  def create
    @chat = current_user.chats.new(chat_params)
    render :validater unless @chat.save
  end

  private

  def chat_params
    params.require(:chat).permit(:message, :room_id)
  end

  def reject_non_related
    user = User.find(params[:id])
    unless current_user.following?(user) && user.following?(current_user)
      redirect_to books_path
    end
  end

end
