with Posix;
with Posix.io;
use Posix.io;

with System; 
with ada.unchecked_conversion;

with Ada.Streams;

package body V4L2 is

	type Byte is mod 2 ** 8;
	for Byte'size use 8;
	type byte_offset is range 0..2**32;
	type bytearray is array(byte_offset range <>) of byte;



	function Open_Video(Default_Device : String := "/dev/video0") return Handle is
		H : Handle;
	begin
		H.FileHandle := Open("/dev/video0",read_only);
		H.Stream_Task := new VideoStream;
		H.Stream_Task.Start(H.FileHandle);
		return H;
	end Open_Video;

	task body VideoStream is 
		use Ada.Streams;
		babuffer : Stream_Element_Array(1..300000) := (others => 0);

		Item_Size : constant Stream_Element_Offset := 
			babuffer'Size / Stream_Element'Size; 
		type SEAPointer is access all Stream_Element_Array(1..Item_Size);
		function To_SEAPointer is 
			new Ada.Unchecked_Conversion(System.Address, SEAPointer);

		last_read : stream_element_offset := 0;

		Current_File : file_descriptor;

	begin

		accept Start(f : file_descriptor) do 
			Current_File := f;
		end;
		loop
			select
				accept Read_Image(ImageContent : out Stream_Element_Array; Last : out Stream_Element_Offset) do
					ImageContent(1..last_read) := babuffer(1..last_read);
					Last := last_read;
				end Read_Image;
			else
				-- read an image

				read(Current_File,To_SEAPointer(babuffer'address).all,last_read);
	
			end select;
		end loop;
	end VideoStream;

	procedure Close(H : in out Handle) is 
	begin
		Close(H.FileHandle);
		
	end Close;

	function Get_Image(H : in Handle) return Stream_Element_Array is
		s : Stream_Element_Array(1..300000);
		l : Stream_Element_Offset;
	begin
		H.Stream_Task.all.Read_Image(s,l);
		return s(1..l);
	end;



end V4L2;


