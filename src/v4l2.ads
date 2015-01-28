
with posix.io;
with Ada.streams;
use Ada.Streams;

package V4L2 is

	type Handle is private;

	-- open the video device, by default, 
	-- /dev/video0, this function returned a handle that must be closed 
	-- using the close procedure
	function Open_Video(Default_Device : String := "/dev/video0") return Handle;

	-- get the image from the device, in it's current format
	function Get_Image(H : in Handle) return Stream_Element_Array;

	-- close the resources associated to the device
	procedure Close(H : in out Handle);

private


	task type VideoStream is
		entry Start(f : Posix.io.file_descriptor);
		entry Read_Image(ImageContent : out Stream_Element_Array;Last : out Stream_Element_Offset); 
	end VideoStream;

	type VideoStream_Access is access VideoStream;

	type Handle is record 
		FileHandle : Posix.io.file_descriptor;
		Stream_Task : VideoStream_Access;
	end record;




end V4L2;

