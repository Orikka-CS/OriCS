--[ S¢Óigma ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=MakeEff(c,"STo")
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCL(1,id)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	
	local e0=MakeEff(c,"STo")
	e0:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e0:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e0:SetCode(EVENT_TO_GRAVE)
	e0:SetCL(1,{id,1})
	WriteEff(e0,0,"TO")
	c:RegisterEffect(e0)
	
end

function s.cost1(e,tg,ep,ev,re,r,rp,chk)
	e:SetLabel(10000)
	return true
end
function s.cost1fil(c,e,tp)
	if not (c:IsHasEffect(id) and not c:IsCode(id) and c:IsAbleToGraveAsCost() and c:IsSetCard(0x6d70) and c:IsAttribute(ATT_D)) then 
		return false
	end
	local eff={c:GetCardEffect(id)}
	for _,teh in ipairs(eff) do
		local te=teh:GetLabelObject()
		local con=te:GetCondition()
		local tg=te:GetTarget()
		if (not con or con(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) 
			and (not tg or tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) then
			return true
		end
	end
	return false
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return false
	end
	if chk==0 then
		if e:GetLabel()~=10000 then
			return false
		end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.cost1fil,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cost1fil,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	Duel.SendtoGrave(g,REASON_COST)
	local tc=g:GetFirst()
	local eff={tc:GetCardEffect(id)}
	local te=nil
	local acd={}
	local ac={}
	for _,teh in ipairs(eff) do
		local temp=teh:GetLabelObject()
		local con=temp:GetCondition()
		local tg=temp:GetTarget()
		if (not con or con(temp,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) 
			and (not tg or tg(temp,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) then
			table.insert(ac,teh)
			table.insert(acd,temp:GetDescription())
		end
	end
	if #ac==1 then
		te=ac[1]
	elseif #ac>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
		op=Duel.SelectOption(tp,table.unpack(acd))
		op=op+1
		te=ac[op]
	end
	if not te then
		return
	end
	local teh=te
	te=teh:GetLabelObject()
	e:SetProperty(te:GetProperty())
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local tg=te:GetTarget()
	if tg then
		tg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	te:SetLabel(e:GetLabel())
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then
		op(e,tp,eg,ep,ev,re,r,rp)
	end
	te:SetLabel(e:GetLabel())
	te:SetLabelObject(e:GetLabelObject())
end

function s.tar0(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.op0(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,1,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
