local utils = {}

function utils.makeDataParallelTable(model, nGPU)
    if nGPU > 1 then
       local gpus = torch.range(1, nGPU):totable()
       local fastest, benchmark = cudnn.fastest, cudnn.benchmark
 
       local dpt = nn.DataParallelTable(1, true, true)
          :add(model, gpus)
          :threads(function()
             local cudnn = require 'cudnn'
             cudnn.fastest, cudnn.benchmark = fastest, benchmark
          end)
       dpt.gradInput = nil
 
       model = dpt:cuda()
    end
    return model
 end
 
 return utils
