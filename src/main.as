import item.*;

import mx.collections.ArrayCollection;
import mx.containers.VBox;
import mx.controls.Alert;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

private var jobs:ArrayCollection = new ArrayCollection();
private var jobletHomeURL:String = "";
private var FrameColor:String = "#000000";
private var TitleWordColor:String = "#ffffff";
private var ContentBgColor:String = "#ffffff";
private var ContentWordColor:String = "#000000";
private var miniWidth:int = 150;
private var wordWidth:int = 100;
private var imageWidth:String = "100%";
private var imageHeight:String = "100%";	
private var params:Object = null;
private var displayMode:String = "v";

private function onLoad(event:Event):void {
	params = Application.application.parameters;
	setColor();
	sendRequest();
}

private function sendRequest():void {
	var request_params:Object = new Object();
    request_params.limit = '20';
    jobService.url = params.service_url;

//	jobService.url = "http://staging.joblet.theplant-dev.com/blogs/1/en/jobs.xml";
//	jobService.url = "http://localhost:3000/blogs/1/ja/jobs.xml";
    jobService.send(request_params);
}

private function onDataResponse(event:ResultEvent):void {
	miniWidth = stage.width - 5;
	
	// set home link and title words
	setWordsAndLinks(event.result.jobs);

	// get the type of item (vertical or horizontal)
	if(stage != null && stage.width > 200) {
		measureHorizontalItemSize();
	} else {
		measureVerticalItemSize();
	}

	if(event.result.jobs.job == null) {
		showNoRecord();
	} else if(event.result.jobs.job is ArrayCollection) { // add property to job object		
		for each (var j:Object in event.result.jobs.job as ArrayCollection) {
			jobs.addItem(buildJob(j));
		}
	} else if(event.result.jobs.job != null) {		
		jobs.addItem(buildJob(event.result.jobs.job));
	}

	bindDataToList();
	loadingBar.visible = false;
}

private function onDataFault(event:FaultEvent):void {
	Alert.show(event.fault.faultString.toString(),"Widget Error!");
}

private function bindDataToList():void {
	var listItem:VBox;
	for each (var job:Object in jobs) {
		if(displayMode == "v") {
			listItem = new ItemVertical();
		} else {
			listItem = new ItemHorizontal();
		}

		listItem.data = job;
		jobList.addChild(listItem);
	}
}

private function buildJob(job:Object):Object {
	var hasPicture:Boolean = (job.image_widget_path != "missing.jpg");

	if(hasPicture) {
		job.imageWidth = imageWidth;
		job.imageHeight = imageHeight;
		job.imageVisibility = true;
	} else {
		job.imageWidth = imageWidth;
		job.imageHeight = "0";
		job.imageVisibility = false;
	}

	job.wordColor = ContentWordColor;
	job.miniWidth = miniWidth;
	job.wordWidth = wordWidth;

	return job;
}

private function measureVerticalItemSize():void {
	displayMode = "v";
	wordWidth = miniWidth * 0.9;
	imageWidth = "100%";
	imageHeight = "100%";
}

private function measureHorizontalItemSize():void {	
	displayMode = "h";
	if((miniWidth * 0.3) > 80) {
		imageWidth = "80";
		wordWidth = miniWidth - 100;
	} else {
		imageWidth = (miniWidth * 0.3).toString();
		wordWidth = miniWidth * 0.6;
	}
	imageHeight = "100%";
}

// set title word and link address
private function setWordsAndLinks(config:Object):void {
	jobletHomeURL = config.link_to_home;
	title.text = config.job_board_name;
	noRecord.text = config.no_record_text;
	linkToHome.label = config.more_jobs_text;
}

// set colors which get from xml
private function setColor():void {
	if(params.frame_color != null) {
		FrameColor = params.frame_color;
		TitleWordColor = params.title_color;
		ContentBgColor = params.content_bg_color;
		ContentWordColor = params.content_color;
	}

	titleFrame.setStyle("backgroundColor", FrameColor);
	title.setStyle("color", TitleWordColor);
	jobList.setStyle("backgroundColor", ContentBgColor);
	footFrame.setStyle("backgroundColor", ContentBgColor);
	footFrame.setStyle("color", ContentWordColor);
	this.setStyle("borderColor", FrameColor);
}

// show no record words
private function showNoRecord():void {
	if(stage != null) {
		noRecord.setStyle("left", stage.width/2 - noRecord.width);
		noRecord.setStyle("top", stage.height/2 - noRecord.height/2);
		noRecord.visible = true;
	}
}

// goto joblet home page
private function gotoJobletHome(event:MouseEvent):void {
	if(jobletHomeURL != "") {
		navigateToURL( new URLRequest( jobletHomeURL ), "_self" );
	}
}