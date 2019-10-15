# HLDDStudio <a href="https://apps.apple.com/app/id1481074240"><img src="https://i.imgur.com/Pc1KdHw.png" width="100"></a>

HLDDStudio is designed to be a simple, flexible and functional music application. Intuitive operation that allows users to create and mix multiple audio files effortlessly on mobile device.

HLDDStudio 
## Features

- ### Mixer
    - Device input output picker
    > 透過左側的 input device picker ，可以更換將要使用在 Mixer 的輸入訊號。右側的 route picker 可以選擇將要使用的輸出裝置
    
    - Metronome 
    >開啟節拍器並選擇特定的速度，則可以透過在播放與錄音的狀態下聽到節拍效果。
    >節拍速度由每分鐘 40 - 240 下

    - Mixer Input picker
    >Mixer Input picker 可選擇將在音軌上使用的訊號源，裝置 (同 input device picker 所選擇裝置)，音樂檔案， drum machine
 
    - Stop Button
    >點擊 Stop Button 將重置（停止）所有狀態（動作）與節拍器功能，如有選擇音樂檔案的音軌，音樂檔案將被重新播放

    - Play And Pause Button
    >點擊 Play And Pause Button 將會在 pause 和 playing 狀態間切換，當點擊 Play Button 將會開始播放預備小節(一次)，並在節拍顯示器為 ```1 / 1 ```時開始播放音樂或啟動 drum machine。
    >點擊 Pause Button 時將會暫停所有音樂播放與節拍器功能，但下一次音軌不會被重新播放，而會從暫停的位置開始
    
    
    - Record 

        **-** 設定
        >在開始錄音前必須設定起始小節與結束小節（結束小節不得早於起始小節），並在任一音軌上選擇有效地音源輸入。

        **-** 開始錄音
        >當設定完成後，點擊 record button ，系統將會自動開始啟動錄音流程，在播放玩預備小節後，裝置將進入可錄音的狀態，並在所設定的起始小節與結束小節，執行錄音的功能，錄製時節拍速度將採用節拍器的速度設定（無論有無開啟）

        **-** 結束錄音
        >當系統自動結束錄音過程，此時錄音檔案才可視為**有效的**錄音檔案並存放在 App 的 ```documents``` 資料夾下，檔案名稱可在錄音前於右側的輸入匡命名，如果無特別命名檔案名稱，系統會將有效的錄音檔案以```時間戳```的命名方式存放檔案
    
    - PlugIn selector
    >當點擊白色按鈕 (切換器）時，顯示器會不斷循環顯示已擁有的效果器。當螢幕顯示為所需效果器時，點擊右側 AddPlugin Button 則會將音軌加上此效果器的功能。（效果器與音源之間以串連的方式連接。不會重複輸出同一音源。）

    - PlugIn editing

        ***-*** 開關
        >效果器右側圓形按鈕可以切換效果器開關狀態
        >
        ***-*** 刪除
        >點擊圓形按鈕並向左側滑動，可以將效果器從音軌上移除

        ***-*** 編輯
        >點擊螢幕上效果器有效區域，則可進入效果器編輯畫面
## Requirements
* iOS 12.0+
* XCode 11.0+
## Libraries
* AudioKit
* G3GridView
* IQKeyboardManager
* MarqueeLabel
* SwipeCellKit
* Firebase
* Crashlytics
## Version History

## Contacts

Ting Hui WU 

wu19931221@gmail.com
