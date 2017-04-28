//
//  MusicViewController.swift
//  SharePic
//
//  Created by Patrick Boyle on 4/23/17.
//  Copyright © 2017 Patrick Boyle. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class MusicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var chooseSongButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var songNameText: UILabel!
    @IBOutlet weak var centTextField: UITextField!
    @IBOutlet weak var centButton: UIStepper!
    
    var audioPlayer = AVAudioPlayer();
    var engine = AVAudioEngine();
    var player = AVAudioPlayerNode();
    var mediaItems = MPMediaQuery.songs().items;
    var pitch = AVAudioUnitTimePitch();
    var buffer = AVAudioPCMBuffer();
    var file = AVAudioFile();
    var cents = 0.0;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centTextField.text = "0";
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        tableView.isHidden = true;

        do
        {
            
            player.volume = 0.5;
            
            loadSong(index: 0);
            
            engine.attach(player);
            engine.attach(pitch);
            engine.connect(player, to: pitch, format: buffer.format);
            engine.connect(pitch, to: engine.mainMixerNode, format: buffer.format);
            player.scheduleBuffer(buffer, completionHandler: nil);
            
            engine.prepare();
            
            do
            {
                try engine.start();
            }
            catch
            {
                print(error);
            }
            
        }
        catch
        {
            print(error);
        }
    }
    

    @IBAction func pressPlay(_ sender: Any) {
        player.play();
    }

    @IBAction func pressPause(_ sender: Any) {
        
        if(player.isPlaying)
        {
            player.pause();
        }
    }
    
    @IBAction func centIncPress(_ sender: Any) {
        cents = centButton.value;
        pitch.pitch = Float(cents);
        centTextField.text = String(Int(cents));
    }
    
    
    @IBAction func pressRestart(_ sender: Any) {
        
        if(player.isPlaying)
        {
            //player.pause();
            //let time = AVAudioTime.self(hostTime: 0);
            //player.play(at: time);
        }
    }
    @IBAction func chooseSongPress(_ sender: Any) {
        tableView.isHidden = false;
        tableView.reloadData();
    }
    
    func loadSong(index: Int)
    {
        songNameText.text = mediaItems![index].title;
        
        if(player.isPlaying)
        {
            player.stop();
        }
        
        let url = mediaItems![index].assetURL;
        file = try! AVAudioFile(forReading: url!);
        
        buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length));
        do
        {
            try file.read(into: buffer);
        }
        catch
        {
            print(error);
        }
        
        pitch.pitch = Float(cents);
        
        if(engine.isRunning)
        {
            player.scheduleBuffer(buffer, completionHandler: nil);
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediaItems?.count ?? 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongCell;
        
        cell.songTitle.text = mediaItems![indexPath.row].title;
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.isHidden = true;
        loadSong(index: indexPath.row);
    }
    
    
}
