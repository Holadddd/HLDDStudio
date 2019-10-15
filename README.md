# HLDDStudio <a href="https://apps.apple.com/app/id1481074240"><img src="https://i.imgur.com/Pc1KdHw.png" width="100"></a>

HLDDStudio is designed to be a simple, flexible and functional music application. Intuitive operation that allows users to create and mix multiple audio files effortlessly on mobile device.

# Features

- ### Mixer
 
    - #### Device input output picker
         透過左側的 **Input Device Picker** ，可以更換 Mixer 將要使用的輸入訊號。右側的 **Route Picker** 可以選擇將要使用的輸出裝置。
         
         <img src="https://github.com/Holadddd/HLDDStudio/blob/feature_UserManualPage/HLDDStudio/GifEffects/HLDDGif_1.gif" width="200">

    - #### Metronome 
        開啟節拍器並選擇特定的速度，則可以透過在播放與錄音的狀態下聽到節拍效果。節拍速度由每分鐘 40 - 240 下。
        
        <img src="https://github.com/Holadddd/HLDDStudio/blob/feature_UserManualPage/HLDDStudio/GifEffects/HLDDGif_2.gif" width="200">
    

    
    - #### Mixer Input picker
        **Mixer Input picker** 可選擇裝置 (同 **Input Device Picker** 所選擇裝置) / 音樂檔案 / Drum machine 為將在音軌上使用的訊號源
        
        <img src="https://github.com/Holadddd/HLDDStudio/blob/feature_UserManualPage/HLDDStudio/GifEffects/HLDDGif_3.gif" width="200">

    - #### Stop Button
        點擊 **Stop Button** 將重置（停止）所有狀態（動作）與節拍器功能，如有選擇音樂檔案的音軌，音樂檔案將被重新播放

    - #### Play And Pause Button
        Play And Pause Button 將會在 pause 和 playing 狀態間切換，當點擊 **Play Button** 將會開始播放預備小節(一次)，並在節拍顯示器為 ```1 / 1 ```時開始播放音樂或啟動 Drum machine。
        點擊 **Pause Button** 時將會暫停所有音樂播放與節拍器功能，但下一次音軌不會被重新播放，而會從暫停的位置開始
    >
    - #### Record 


         - 設定
         
        在開始錄音前必須設定起始小節與結束小節（結束小節不得早於起始小節）和節奏速度（預設為 60 BPM），並在任一音軌上選擇有效地音源輸入。

         - 開始錄音
         
        當設定完成後，點擊 **Record Button** ，系統將會自動開始啟動錄音流程，在播放玩預備小節後，裝置將進入可錄音的狀態，並在所設定的起始小節與結束小節，執行錄音的功能，錄製時節拍速度將採用節拍器的速度設定（無論有無開啟）

         - 結束錄音
         
        當系統自動結束錄音過程，此時錄音檔案才可視為**有效的**錄音檔案並存放在 App 的 ```documents``` 資料夾下，檔案名稱可在錄音前於右側的輸入匡命名，如果無特別命名檔案名稱，系統會將有效的錄音檔案以```時間戳```的命名方式存放檔案
        
        <img src="https://github.com/Holadddd/HLDDStudio/blob/feature_UserManualPage/HLDDStudio/GifEffects/HLDDGif_4.gif" width="200">
        
    
    - #### PlugIn selector
        當點擊白色按鈕 (切換器）時，顯示器會不斷循環顯示已擁有的效果器。當螢幕顯示為所需效果器時，點擊右側 **AddPlugin Button** 則會將音軌加上此效果器的功能。（效果器與音源之間以串連的方式連接。不會重複輸出同一音源。）
        
        
    
    - #### PlugIn editing

        - 開關
        
        效果器右側圓形按鈕可以切換效果器開關狀態
        
        - 刪除
        
        點擊圓形按鈕並向左側滑動，可以將效果器從音軌上移除

        - 編輯
        
        點擊螢幕上效果器有效區域，則可進入效果器編輯畫面
        
        <img src="https://github.com/Holadddd/HLDDStudio/blob/feature_UserManualPage/HLDDStudio/GifEffects/HLDDGif_5.gif" width="200">
        
        <img src="https://github.com/Holadddd/HLDDStudio/blob/feature_UserManualPage/HLDDStudio/GifEffects/HLDDGif_6.gif" width="200">
    
     
    - #### Pan knob
        點擊 **Pan knob** 並上下滑動，可控制音軌輸出的左右聲道平衡
    
    - #### Equalizer knob
        **Equalizer knob** 分別控制低頻（64Hz）、中頻（2kHz）、高頻（12kHz），在帶寬（Bandwidth）為 **1** 的狀態下，點擊 **Equalizer knob** 並上下滑動，可針對音軌輸出的頻率做 0% - 100% 的音量調整
    
    - #### Volume fader
        上下滑動 **Volume fader** 可控制音軌上 0% - 100% 的音量調整。
        **Master Volume fader** 為總裝置 0% - 100% 的音量調整。
    


- ## DrumMachine
    - #### Drumkit Sample selected and played
        點選 **Drumkit Picker** 可以選擇將要播放的 Drumkit category(Kicks, Snare, Percussion, Hihats, Classic)
        點選 **Samples Picker** 可以選擇不同的 sample source
        點選左側 **Sample Button** 可以播放所選擇的 sample source
        
        <img src="https://github.com/Holadddd/HLDDStudio/blob/feature_UserManualPage/HLDDStudio/GifEffects/HLDDGif_7.gif" width="200">
    

    - #### Pan knob
        點擊 **Pan Knob** 並上下滑動，可控制所選擇 sample source 在鼓機播放時的左右聲道平衡
    - #### Track volume fader
        上下滑動 **Volume Fader** 可控制所選擇 sample source 0% - 100% 的音量調整。
    - #### DrumMachineEditor
        
        點擊 **Rotated Button** 可以依據不同使用情境做畫面調整
        
        當畫面呈現直立時， Editor 可以依據使用者喜好隨意拖拉方向（不侷限單一方向）
        
        當畫面呈現水平時， Editor 將呈現全部 **16** 拍的編輯狀態，提供更快速地編輯方式
        
        點選 Editor 按鈕時，則會切換 sample source 在 drum machine 的播放狀態
        
        點擊播放鍵啟動並播放 Drum machine ，播放狀態的按鈕（藍色）會呈現閃光動畫
        
        <img src="https://github.com/Holadddd/HLDDStudio/blob/feature_UserManualPage/HLDDStudio/GifEffects/HLDDGif_8.gif" width="200">
        
        <img src="https://github.com/Holadddd/HLDDStudio/blob/feature_UserManualPage/HLDDStudio/GifEffects/HLDDGif_9.gif" heigh="200">

    - #### Tempo Selector
        
        **Tempo Picker** 可調整鼓機啟動後的播放速度 
    
    


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

## Contacts

Ting Hui WU 

wu19931221@gmail.com
