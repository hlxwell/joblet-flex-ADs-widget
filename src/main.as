import item.HorizontalItem;
import item.VerticalItem;
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

//	jobService.url = "http://staging.joblet.theplant-dev.com/blogs/1/ja/jobs.xml";
	jobService.url = "http://localhost:3000/blogs/1/ja/jobs.xml";
    jobService.send(request_params);
}

private function onDataResponse(event:ResultEvent):void {
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

	loadingBar.visible = false;
}

private function buildJob(job:Object):Object {
	if(job.image_widget_path == "missing.jpg") {
		job.imageWidth = "0";
		job.imageHeight = "0";
		job.itemHeight = itemHeight;
		imageVisibility = false;
	} else {
		job.imageWidth = imageWidth;
		job.imageHeight = imageHeight;
		job.itemHeight = 120;
		imageVisibility = true;
	}

	job.wordColor = ContentWordColor;
	job.miniWidth = miniWidth;
	job.wordWidth = wordWidth;
	job.imageVisibility = imageVisibility;
	
	return job;
}

private function onDataFault(event:FaultEvent):void {
	Alert.show(event.fault.faultString.toString(),"Widget Error!");
}

private function measureVerticalItemSize():void {
	trace("vertical");
	
	jobList.itemRenderer = new ClassFactory(VerticalItem);
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

	jobList.itemRenderer = new ClassFactory(HorizontalItem);
	
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
//	upArrow.setStyle("color", ContentWordColor);
//	downArrow.setStyle("color", ContentWordColor);
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

// page up and page down
private function pageUp(event:MouseEvent):void {
	if( (jobList.verticalScrollPosition - jobList.rowCount) <= 0 ) {
		jobList.verticalScrollPosition =  0;
	} else {
		jobList.verticalScrollPosition -= jobList.rowCount;
	}
}

private function pageDown(event:MouseEvent):void {
	if( (jobList.verticalScrollPosition + jobList.rowCount) > jobList.maxVerticalScrollPosition ) {
		jobList.verticalScrollPosition = jobList.maxVerticalScrollPosition;
	} else {
		jobList.verticalScrollPosition += jobList.rowCount;
	}
}