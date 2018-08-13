require 'torch'
require 'paths'
require 'cudnn'
require 'cunn'
require 'image'

local t = require 'datasets/transforms'

if #arg < 2 then
   io.stderr:write('Usage: th classify.lua [MODEL] [DIRECTORY]...\n')
   os.exit(1)
end

local function findImages(dir)
    -- Returns a table with all the image paths found in 
    -- dir using 'find'
   local imagePath = torch.CharTensor()

   ----------------------------------------------------------------------
   -- Options for the GNU and BSD find command
   local extensionList = {'jpg', 'png','JPG','PNG','JPEG', 'ppm', 'PPM', 'bmp', 'BMP'}
   local findOptions = ' -iname "*.' .. extensionList[1] .. '"'
   for i=2,#extensionList do
      findOptions = findOptions .. ' -o -iname "*.' .. extensionList[i] .. '"'
   end

   -- Find all the images using the find command
   local f = io.popen('find -L ' .. dir .. findOptions)

   local maxLength = -1
   local imagePaths = {}
   --local imageClasses = {}

   while true do
      local line = f:read('*line')
      if not line then break end

      local filename = paths.basename(line)
      local path = paths.dirname(line) .. '/' .. filename

      table.insert(imagePaths, path)

      maxLength = math.max(maxLength, #path + 1)
   end

   f:close()

   return imagePaths

end

-- Load the model
local model = torch.load(arg[1])

-- function to Test Current Model on Test Data
function test()
    confusion:zero()
    model:evaluate()
    for input, target in dataGen:valGenerator(batchSize) do
        -- Forward pass
        output = model:forward(input)
        confusion:batchAdd(output, target)
    end
    
    confusion:updateValids()
    testAcc = self.confusion.totalValid*100
    print('Test Accuracy = ' .. testAcc)
end

-- Ten Crops
local t = require 'datasets/transforms'
local transform = t.Compose{
   t.Scale(256),
   t.ColorNormalize(t.meanstd),
   t.TenCrop(224),
}


function string_output(output)
    local string_print = ''
    for i = 1, 38 do
       string_print = string_print .. ', ' .. output[i]
    end
    return string_print
 end

 all_test_paths = findImages(arg[2])

-- predict for all image
for _,imgpath in ipairs(findImages(arg[2])) do
   local img = image.load(imgpath, 3, 'float')
   local name = paths.basename(imgpath)
   
   -- Scale, normalize, and ten crop the image
   -- View as mini-batch of size 10
   img_batch = transform(img)

   -- Get the output of the softmax and average it
   local output = model:forward(img_batch):mean(1)[1]

    -- print the name and output in correct form.
end

