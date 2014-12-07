
with posix.io;
with Ada.streams;
use Ada.Streams;

package V4L2 is

	type Handle is private;

	function Open_Video(Default_Device : String := "/dev/video0") return Handle;
	function Get_Image(H : in Handle) return Stream_Element_Array;
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

