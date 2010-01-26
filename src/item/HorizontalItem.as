package item
{
	import flash.events.MouseEvent;
	import flash.net.*;
	
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.*;

	public class HorizontalItem extends VBox
	{
		public var hbox:HBox;
		public var rightColumn:VBox;
		public var jobImage:Image;
		public var jobTitle:Text;
		public var jobSalary:Label;
		public var jobCompany:Label;
		public var hrule:HRule;
		
		public function HorizontalItem()
		{   		
			super();
		}
		
		private function init():void {
			this.verticalScrollPolicy 	= "off";
			this.horizontalScrollPolicy = "off";
			this.height					= 120;
			this.setStyle("width", "100%");
    		this.setStyle("verticalGap", "0");

			hbox = new HBox();
			hbox.setStyle("width", "100%");

			rightColumn = new VBox();
			rightColumn.setStyle("width", data.wordWidth);

			jobImage = new Image();
    		jobImage.height 			= data.imageHeight;
    		jobImage.width 				= data.imageWidth;
    		jobImage.visible 			= data.imageVisibility; 
			jobImage.source 			= data.image_widget_path;
    		jobImage.addEventListener(MouseEvent.CLICK, gotoCompany);
  
  			jobTitle = new Text();
			jobTitle.width 				= data.wordWidth;
    	 	jobTitle.setStyle("textAlign", "left");
    		jobTitle.text 				= data.title;
    		jobTitle.setStyle("color", data.wordColor);
    		jobTitle.useHandCursor 		= true;
    		jobTitle.mouseChildren 		= false;
    		jobTitle.buttonMode 		= true;
    		jobTitle.styleName			= "htmlLinkHover";
    		jobTitle.addEventListener(MouseEvent.CLICK, gotoJob);

			jobSalary = new Label();
			jobSalary.width				= data.wordWidth;
			jobSalary.setStyle("color", data.wordColor);
	    	jobSalary.text				= data.salary;
		   	jobSalary.setStyle("textAlign", "left");
			
			jobCompany = new Label();
			jobCompany.width			= data.wordWidth;
	    	jobCompany.setStyle("color", data.wordColor);
	    	jobCompany.setStyle("textAlign", "left");
	    	jobCompany.text				= data.company;
			jobCompany.styleName		= "htmlLinkHover1";
			jobCompany.addEventListener(MouseEvent.CLICK,gotoCompany);

			hrule = new HRule();
			hrule.setStyle("width", "100%");
			hrule.height 				= 1;

			// add component to stage			
			rightColumn.addChild(jobTitle);
			rightColumn.addChild(jobSalary);
			rightColumn.addChild(jobCompany);
			hbox.addChild(jobImage);
			hbox.addChild(rightColumn);
			this.addChild(hbox);
			this.addChild(hrule);
		}
		
		private function gotoCompany(event:MouseEvent):void {
			navigateToURL( new URLRequest( data.link_to_company ), "_self" );
		}

		private function gotoJob(event:MouseEvent):void {
			navigateToURL( new URLRequest( data.link_to_job ), "_self" );
		}

		override public function set data(value:Object):void
        {
            if(value != null)
            {
                super.data = value;
                init();
            }
        }
	}
}