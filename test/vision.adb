
with V4L2;use V4L2;
with Ada.text_io;
use Ada.Text_io;
with Ada.Streams;
use Ada.Streams;

--
-- test program, reading images from the camera
--
procedure Vision is 
	H : V4L2.Handle := Open_Video;
begin
	Put_Line("Video opened");
	Put_Line(" Read an Image");

	for i in 1..100 loop
		declare
			a : Stream_Element_Array := Get_Image(H);
		begin
			delay 1.0;
			Put_Line("Elements read :" & Integer'Image(a'length));
		end;
	end loop;

	
	Close(H);	

end Vision;



