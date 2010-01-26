import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

[Bindable]
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
private var itemHeight:int = 80;
private var imageVisibility:Boolean = true;			
private var params:Object = null;

private function onLoad(event:Event):void {
	params = Application.application.parameters;
	setColor();
	sendRequest();
}

private function sendRequest():void {
	var request_params:Object = new Object();
    request_params.limit = '100';
    jobService.url = params.service_url;

	//jobService.url = "http://staging.joblet.theplant-dev.com/blogs/1/ja/jobs.xml";
	//jobService.url = "http://atom.joblet.theplant-dev.com/blogs/1/en/jobs.xml";
	//jobService.url = "file:///Users/michael/Desktop/jobs.xml";
	jobService.url = "http://localhost:3000/blogs/1/ja/jobs.xml";
    jobService.send(request_params);
}

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
	upArrow.setStyle("color", ContentWordColor);
	downArrow.setStyle("color", ContentWordColor);
	this.setStyle("borderColor", FrameColor);
}





private function onDataResponse(event:ResultEvent):void {
	var new_jobs:ArrayCollection = new ArrayCollection();

	// set home link and title words
	jobletHomeURL = event.result.jobs.link_to_home;
	title.text = event.result.jobs.job_board_name;
	noRecord.text = event.result.jobs.no_record_text;
	linkToHome.label = event.result.jobs.more_jobs_text;

	// get the type of item (vertical or horizontal)
	if(stage != null && stage.width > 200) {
		measureHorizontalItemSize();
	} else {
		measureVerticalItemSize();
	}

	if(event.result.jobs.job == null) {
		showNoRecord();
	} else if(event.result.jobs.job is ArrayCollection) {
		// add property to job object
		for each (var j:Object in event.result.jobs.job as ArrayCollection) {
			if(j.image_widget_path == "missing.jpg") {
				j.imageWidth = "0";
				j.imageHeight = "0";
				j.itemHeight = itemHeight;
				imageVisibility = false;
			} else {
				j.imageWidth = imageWidth;
				j.imageHeight = imageHeight;
				j.itemHeight = 120;
				imageVisibility = true;
			}
trace(j.itemHeight);
			j.wordColor = ContentWordColor;
			j.miniWidth = miniWidth;
			j.wordWidth = wordWidth;
			j.imageVisibility = imageVisibility;
			new_jobs.addItem(j);
		}
	} else if(event.result.jobs.job != null) {
		var jj:Object = event.result.jobs.job;
		if(j.image_widget_path == "missing.jpg") {
			jj.imageWidth = "0";
			jj.imageHeight = "0";
			jj.itemHeight = itemHeight;
			imageVisibility = false;
		} else {
			jj.imageWidth = imageWidth;
			jj.imageHeight = imageHeight;
			jj.itemHeight = 120;			
			imageVisibility = true;
		}
		jj.wordColor = ContentWordColor;
		jj.miniWidth = miniWidth;
		jj.wordWidth = wordWidth;
		jj.imageVisibility = imageVisibility;
		new_jobs.addItem(jj);
	}

	jobs = new_jobs;				
	loadingBar.visible = false;
}

private function measureVerticalItemSize():void {
	trace("vertical");
	jobList.columnCount = 1;
	jobList.columnWidth = stage.width - 5;

	miniWidth = jobList.columnWidth;
	wordWidth = miniWidth;

//	imageWidth = "100";
	imageHeight = "40";

	// decide the row count
	trace(stage.height);
//	jobList.rowCount = (stage.height - 55) / 100;
	trace(jobList.rowCount);
}

private function measureHorizontalItemSize():void {	
	trace("horizontal");		
	// decide the column count and width
	if(stage.width > miniWidth && stage.width < 560) {
		jobList.columnWidth = stage.width - 5;
		jobList.columnCount = 1;
	} else if(stage.width >= 560 && stage.width < 840) {
		jobList.columnWidth = stage.width/2 - 5;
		jobList.columnCount = 2;
	} else if(stage.width <= miniWidth) {						
		jobList.columnWidth = miniWidth - 5;
		jobList.columnCount = 1;
	} else if(stage.width >= 840) {
		jobList.columnWidth = stage.width/3 - 5;
		jobList.columnCount = 3;
	}

	miniWidth = jobList.columnWidth;
	wordWidth = miniWidth * 0.6;

	imageWidth = (miniWidth * 0.3).toString();
//	imageHeight = 20;
	
	// decide the row count
	jobList.rowCount = (stage.height - 55) / 85;
}





private function showNoRecord():void {
	if(stage != null) {
		noRecord.setStyle("left", stage.width/2 - noRecord.width);
		noRecord.setStyle("top", stage.height/2 - noRecord.height/2);
		noRecord.visible = true;
	}
}

private function gotoJobletHome(event:MouseEvent):void {
	if(jobletHomeURL != "") {
		navigateToURL( new URLRequest( jobletHomeURL ), "_self" );
	}
}

private function onDataFault(event:FaultEvent):void {
	Alert.show(event.fault.faultString.toString(),"Widget Error!");
}

// page up and page down
private function pageUp(event:MouseEvent):void {
	if( (jobList.verticalScrollPosition - jobList.rowCount) <= 0 ) {
		jobList.verticalScrollPosition =  0;
		showFlashWord("Already First Page!");
	} else {
		jobList.verticalScrollPosition -= jobList.rowCount;
	}
}

private function pageDown(event:MouseEvent):void {
	if( (jobList.verticalScrollPosition + jobList.rowCount) > jobList.maxVerticalScrollPosition ) {
		jobList.verticalScrollPosition = jobList.maxVerticalScrollPosition;
		showFlashWord("Already Last Page!");
	} else {
		jobList.verticalScrollPosition += jobList.rowCount;
	}
}

private function showFlashWord(str:String):void {
//	loadingBar.visible = true;
}
