local button = {}

--**por ordem de prioridade**

--setar posicao
--setar tamanho
--setar cor
--setar texto
--setar alinhamento do texto
--setar fonte
--setar visibilidade

--setar cor hover
--setar callback
--setar transicao
--setar modo de desenho (fill, line)
--setar formato

--inserir animacoes de hover 
--inserir animacoes de click
--adicionar opcoes de som 

--alguma forma de fazer outline do texto
--pensar depois em alguma forma de manter lista de botoes

local buttonList = {} --lista com as listas de paramentros dos botoes -->Problema: se temos varios estados, como organizar os botoes por estado? 
--do jeito atual os botoes sao exibidos na proxima tela. A solucao seria tirar a lista do modulo e deixar por estado ou arranjar um jeito de arrumar a lista por tela

local buttonFunctions = {} --todas as funcoes que uma instancia de botao pode chamar

---------------------------------------funcoes do "objeto"------------------------------------------
button.newList = function() --limpa a lista para apenas exibir os botoes do estado atual
  for i=1, #buttonList do 
    buttonList[i] = nil 
  end
end


button.new = function(text, x, y, width, height, color, font, callback, ...)  -- cria uma instancia de botao
  local btnCnfg = {}
  btnCnfg.id          = #buttonList+1 --rever essa parte
  btnCnfg.callback    = callback or print
  btnCnfg.args        = {...} or nil
    
  btnCnfg.x           = x or 0
  btnCnfg.y           = y or 0
  btnCnfg.width       = width or 200
  btnCnfg.height      = height or 50
  
  btnCnfg.color       = color or {1, 0, 0}
  btnCnfg.hoverColor  = hoverColor or {0.4, 0, 0}
  btnCnfg.textColor   = {1, 1, 1} 
  
  btnCnfg.visible     = true
  btnCnfg.hovered     = false            
  btnCnfg.shadow      = false
  
  btnCnfg.font        = font or love.graphics.newFont(24)
  btnCnfg.text        = love.graphics.newText(btnCnfg.font, text or "label")

  table.insert(buttonList, btnCnfg)
  
  local aux = {}
  aux.id = #buttonList --a posicao do botao na lista é sua proprio indice
  
  setmetatable(aux, buttonFunctions) --talvez possa remover essa linha e retornar direto a buttonFunctions?
  buttonFunctions.__index = buttonFunctions
  
  return aux --retorna referencia a uma tabela com as funcoes acessiveis pela instancia, mais a id do botao
end

button.update = function() --atualiza todos os botoes
  for i, btn in ipairs(buttonList) do
    buttonFunctions:update(btn.id)
  end
end


button.draw = function() --desenha todos os botoes
  for i, btn in ipairs(buttonList) do
    buttonFunctions:draw(btn.id)
  end
end

button.mousepressed = function(x, y, button) --desenha todos os botoes
  for i, btn in ipairs(buttonList) do
    buttonFunctions:mousepressed(btn.id, x, y, button)
  end
end

-----------------------------Funcoes da instancia---------------------------
buttonFunctions.update = function(self, id)
  
  local b = buttonList[self.id] or buttonList[id]
  local mx, my = love.mouse.getPosition()
          
  b.hovered = mx > b.x and mx < b.x + b.width and 
              my > b.y and my < b.y + b.height
end

buttonFunctions.draw = function(self, id) --passar parametro alternativo id para ser usado na funcao de update ou draw all
  
  local b = buttonList[self.id] or buttonList[id]
  
  if b.visible then
    
    --sombra
    --love.graphics.setColor(0, 0, 0, 0.2)
    --love.graphics.rectangle("fill", b.x, b.y, b.width, b.height+6)
    
    if b.hovered then
      love.graphics.setColor(b.hoverColor)
    else
      love.graphics.setColor(b.color)
    end
    
    love.graphics.rectangle("fill", b.x, b.y, b.width, b.height)
    
    
    local offset_x = (b.width - b.text:getWidth())/2
    local offset_y = (b.height-b.text:getHeight())/2
    love.graphics.setColor(b.textColor)
    love.graphics.draw(b.text, b.x+offset_x, b.y+offset_y)
             
    love.graphics.setColor(1, 1, 1)
  end
end

buttonFunctions.mousepressed = function(self, id, x, y, button)
  
  local b = buttonList[self.id] or buttonList[id]
  
  if b.hovered then
    if button == 1 then
      return b.callback(unpack(b.args)) --melhor verificar callback diferente de nil ou deixar print mesmo??
    end
  end
end



buttonFunctions.setPosition = function(self, newX, newY)
  buttonList[self.id].x = newX
  buttonList[self.id].y = newY
end

buttonFunctions.setDimensions = function(self, newWidth, newHeight)
  buttonList[self.id].width = newWidth
  buttonList[self.id].height = newHeight
end

buttonFunctions.setColor = function(self, newColor, hoverColor, textColor)
  
  local btn = buttonList[self.id]
  
  if newColor ~= nil then
    btn.color = newColor
  end
  
  if hoverColor ~= nil then
    btn.hoverColor = hoverColor
  end

  btn.textColor = textColor or btn.textColor
end

buttonFunctions.setText = function(self, newText)
  buttonList[self.id].text = newText
end

buttonFunctions.setVisible = function(self, newVisibility)
  buttonList[self.id].visible = newVisibility
end

buttonFunctions.getId = function(self)
  print(self.id)
end

return button