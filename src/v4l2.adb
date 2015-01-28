with Posix;
with Posix.io;
use Posix.io;

with System; 
with ada.unchecked_conversion;

with Ada.Streams;

package body V4L2 is

	type Byte is mod 2 ** 8;
	for Byte'size use 8;
	type Byte_Offset is range 0..2**32;
	type Byte_Array is array(Byte_Offset range <>) of byte;

	-- default buffer size for reading the images
	Image_Buffer_Size : constant Ada.Streams.Stream_Element_Offset := 300_000;


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

		-- buffer for the latest read image (JPEG format)
		Ba_Buffer : Stream_Element_Array(1..Image_Buffer_Size) := (others => 0);

		Item_Size : constant Stream_Element_Offset := 
			Ba_Buffer'Size / Stream_Element'Size; 
		type SEAPointer is access all Stream_Element_Array(1..Item_Size);
		function To_SEAPointer is 
			new Ada.Unchecked_Conversion(System.Address, SEAPointer);

		Last_Read : Stream_Element_Offset := 0;

		Current_File : File_Descriptor;

	begin
		-- first the task wait for the file descriptor
		accept Start(f : File_Descriptor) do 
			Current_File := f;
		end;

		-- then we loop for image aquisition
		loop
			select
				accept Read_Image(ImageContent : out Stream_Element_Array; Last : out Stream_Element_Offset) do
					ImageContent(1..Last_Read) := Ba_Buffer(1..Last_Read);
					Last := Last_Read;
				end Read_Image;
			else
				-- read an image
				read(Current_File,To_SEAPointer(Ba_Buffer'address).all,Last_Read);
	
			end select;
		end loop;
	end VideoStream;

	procedure Close(H : in out Handle) is 
	begin
		Close(H.FileHandle);
		
	end Close;

	function Get_Image(H : in Handle) return Stream_Element_Array is
		s : Stream_Element_Array(1..Image_Buffer_Size);
		l : Stream_Element_Offset;
	begin
		H.Stream_Task.all.Read_Image(s,l);
		return s(1..l);
	end;



end V4L2;


