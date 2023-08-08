function makekmz(img,lat,lon,varargin)
%
% function makekmz(img,lat,lon,opt,optval)
%
% utility routine to create a kmz Google Earth overlay file from 
% a rectangular image img with arbitrary north/south alignment 
% given corresponding  pixel lat/lon locations.  Uses optional 
% arguments to specify processing options.  Can automatically 
% segment the output image into smaller pieces for easier 
% display in GoogleEarth on small graphics memory machines.
% can embed rotated input image into lat/lon image array
%
% note: lat,lon arrays can be either 2x2 arrays whose corner values
% specify the locations of the corners of the img array OR lat and
% can be one entry for each pixel.  By convention, for a [N,M]=size(img)
% non=rotated image img(1,1) is at the north-most and west-most corner.  
% img(*,1) decreases in latitude.  img(1,*) increases in longitude.  
% The matlab displayed array (axis ij) thuss appear similar to 
% the GoogleEarth display when aligned with north upward.
%
% Unless specified options require one argument
%    opt  arg          function 
%  imname (text):      output file name .kmz extension added [default 'default']
%  alpha (arg):        use alpha array (may be converted to transparency if 
%                       cmap also specified, see notes) with values 0 or 1
%                       (arg=alpha_map which must be the same size as img)
%  RotAngle (none):    enable image rotation/embedding [default unset]
%  RotLatLon (int):    rotation flag: grid in northing/easting if one 
%                       grid in lat/lon if 0 [default 1
%  destdir (txt):      destination directory [default './']
%  scale (arg):        scale img (on argument formated as [max min])
%                       [default [min(min(img)) max(max(img))]
%  cmap (arg):         use color map cmap for image 256 entries with 
%                       [r g b] each 0..1 [default gray()]
%  forcegray:          force use of gray scale even if cmap specified
%                        [default unset]
%  fignum (int):       display final image in figure(fignum) [default none]
%  timecode (arg):     add time code to kmz (arg=[YYYY,MM,DD,hh,mm,ss])
%                       [default none]
%  placemark (2 args): add placemark (requires 2 args: name, [lon,lat,alt])
%                       can specify multiple placemarks [default none]
%  segment (none):     segment image into subimage tiles of maxsize 
%                       if set [default set]
%  nosegment (none):   prevent (override) image segmentation [default unset]
%  maxsize (int):      segment (tile) image size [default 1024]
%  background (int):   background color index used in rotation [default 0]
%  nameprefix (text):  initial text applied to image name in kmz [default '']
%  copyright (text):   include copyright information in kmz png image
%                        file(s) [default none]
%  comment (text):     include comment in kmz png image file(s) [default 'none']%  nameprefix (text):  prefix text to internal kmz image name [default 'none']
%  workdir (/tmp):     temporary work area [default '/tmp']
%  quiet (none):       progress output [default set]
%  debug (none):       enable debug output [default unset]
%
% Note: to handle transparency when cmap is specified (needed when RotAngle
% is specified or alpha is provided), the bottom value of cmap is used for
% indicating transparency of the image.  img value that map to bottom cmap
% value are converted to the second value of cmap.
% written by David Long  9 Dec 2011
% set default values for input args

makekmz_readANDdefaults

North=max(max(lat));South=min(min(lat));West=min(min(lon));East=max(max(lon));

  val=img;
  val(isnan(val))=0;  % remove any NaNs
  minout=0;%min(min(val));
  maxout=255;%max(max(val));
  
  background=0;

%   val=rot90(flipud(val),-1);%val'; % equivalent to rot90(flipud(val),-1);
  
% if figure display asked for, display matlab figure of image
if exist('fignum','var')==1
  figure(fignum);clf;
  if 1 % image displayed with lat/lon axes
    ResE=(East-West)/size(val,2);
    ResN=(North-South)/size(val,1);
    imagesc(West:ResE:East,South:ResN:North,rot90(val),[minout maxout]);
    axis xy
    xlabel('longitude');ylabel('latitude');
  else % image displayed in matlab image form
    imagesc(rot90(val),[minout maxout]);
    xlabel('col index');ylabel('row index');
  end
  colorbar;
  if exist('cmap','var')==1
    colormap(cmap);   % apply user colormap
  else
    colormap('gray'); % apply default grayscale colormap
  end
  % add figure title string
  titlestr=sprintf('%s%s',nameprefix,imname);
  % escape any underbars in title for nice display of image name
  ind=find(titlestr=='_');
  if length(ind)>0
    for k=length(ind):-1:1
      if ind(k)==1
	titlestr=sprintf('\\%s',titlestr(ind(k):end));
      else
	titlestr=sprintf('%s\\%s',titlestr(1:ind(k)-1),titlestr(ind(k):end));
      end
    end
  end
  % add figure title
  title(titlestr);
end
% a kmz file is a zipped directory containing one .kml file
% and one or more image (e.g. png) files referenced in kml file
% put these in a subdirectory 
%% generate .kmz file by first creating .kml and image files in a temporary
%% directory and zipping together to create the .kmz
% temporary work name
tmpkml=sprintf('%s%c%s',tmp,filesep(),imname);
% create temporary working directory 
[success,message,messageid]=mkdir(tmp,imname);
if success==1 % make sure it is empty
  delete(sprintf('%s%c*',tmpkml,filesep()));
end
% create .kml file and write header
outfile=sprintf('%s%c%s.kml',tmpkml,filesep(),imname);
fid=fopen(outfile,'w');
fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(fid,'<kml xmlns="http://earth.google.com/kml/2.0">\n');
fprintf(fid,'<Folder>\n');
fprintf(fid,'<name>%s%s</name>\n',nameprefix,imname);

fprintf(fid,' <LookAt>\n');
fprintf(fid,'  <longitude>%f</longitude>\n',(East+West)*0.5);  % view center
fprintf(fid,'  <latitude>%f</latitude>\n',(North+South)*0.5);
fprintf(fid,'  <range>1000</range>\n');             % viewing height
fprintf(fid,'  <tilt>0</tilt>\n');                  % terrain tilt
fprintf(fid,' <heading>0</heading>\n');             % view heading
fprintf(fid,'</LookAt>\n');

% if image is not segmented (tiled)
  fprintf(fid,'<GroundOverlay>\n');
  fprintf(fid,'<name>%s%s</name>\n',nameprefix,imname);
  fprintf(fid,'<color>ffffffff</color>\n');
  fprintf(fid,' <Icon>\n');
  fprintf(fid,'  <href>%s.png</href>\n',imname);
  fprintf(fid,'  <viewBoundScale>0.75</viewBoundScale>\n');
  fprintf(fid,' </Icon>\n');
  fprintf(fid,' <LatLonBox>\n');
  fprintf(fid,'  <north> %f</north>\n',North);
  fprintf(fid,'  <south> %f</south>\n',South);
  fprintf(fid,'  <west> %f</west>\n',West);
  fprintf(fid,'  <east> %f</east>\n',East);
  fprintf(fid,' </LatLonBox>\n');
  fprintf(fid,'</GroundOverlay>\n');
  fprintf(fid,'</Folder>\n');
  fprintf(fid,'</kml>\n');
  fclose(fid);
  % write out image to png
  fname=sprintf('%s%c%s%c%s.png',tmp,filesep(),imname,filesep(),imname);
  
  % scale the input array to [0..255]
  out1=val;
  out1(out1<0)=0; out1(out1>255)=255;
  % create 8 bit PNG file with desired options
  
%     if exist('alphaa','var')
%       disp('write with alpha channel but no colormap')
%       imwrite(uint8(out1'),fname,'png','Alpha', alphaa','BitDepth',8,copyright,copyrightowner,'Comment',comment);
%     else
%       disp('write without colormap or alpha channel')
    alphaa=ones(size(out1))*0.65;alphaa=alphaa(:,:,1);
      imwrite(uint8(out1),fname,'png','Alpha',alphaa);
%     end

% zip working directory to create .kmz file
zip([destdir filesep() imname '.kmz.zip'],[tmpkml filesep() '*']);
[status,message,messageid]=movefile([destdir filesep() imname '.kmz.zip'], [destdir filesep() imname '.kmz']);
if status ~= 1
  error(['*** failed to rename final .kmz file *** ' message])
end
% remove temporary directory and contents
[status,message,messageid]=rmdir(tmpkml,'s');
if debugflag || quiet
  disp(sprintf('Created kmz file: %s%c%s.kmz',destdir,filesep(),imname));
end
