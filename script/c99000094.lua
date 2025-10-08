--나니☆코레
local s,id=GetID()
function s.initial_effect(c)
	--일반인은 여기서 냉큼 꺼지시지!
	local e1a=Effect.CreateEffect(c)
	e1a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1a:SetCode(EVENT_STARTUP)
	e1a:SetRange(LOCATION_ALL)
	e1a:SetOperation(s.start_op)
	Duel.RegisterEffect(e1a,0)
	--LP 주작은 뭐야
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,5))
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_ALL)
	e2:SetSpellSpeed(3)
	e2:SetOperation(s.lp_op)
	c:RegisterEffect(e2)
	--수치 주작은 뭐야
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,6))
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_ALL)
	e3:SetSpellSpeed(3)
	e3:SetOperation(s.change_op)
	c:RegisterEffect(e3)
	--종족 / 속성 주작은 뭐야
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,7))
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_ALL)
	e4:SetSpellSpeed(3)
	e4:SetOperation(s.rcatt_op)
	c:RegisterEffect(e4)
	--주사위 주작은 뭐야
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_TOSS_DICE_NEGATE)
	e5:SetRange(LOCATION_EXTRA)
	e5:SetOperation(s.dice_op)
	c:RegisterEffect(e5)
	--코인 토스 주작은 뭐야
	local e6=e5:Clone()
	e6:SetCode(EVENT_TOSS_COIN_NEGATE)
	e6:SetOperation(s.coin_op)
	c:RegisterEffect(e6)
end
function s.start_op(e)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	if c:IsLocation(LOCATION_ALL) then
		Duel.DisableShuffleCheck()
		Duel.SendtoDeck(c,nil,-2,REASON_RULE)
	end
end
function s.lp_op(e,tp,eg,ep,ev,re,r,rp)
	local val=0
	local ct=math.floor(10000/100)
	local t={}
	for i=1,ct do
		t[i]=i*100
	end
	val=Duel.AnnounceNumber(tp,table.unpack(t))
	op=Duel.SelectOption(tp,aux.Stringid(id,8),aux.Stringid(id,9),aux.Stringid(id,15))+20
	if op==20 then
		Duel.SetLP(tp,val)
	elseif op==21 then
		Duel.SetLP(1-tp,val)
	end
end
function s.change_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local val=0
	local t={}
	for i=1,251 do
		t[i]=i-1
	end
	if not Duel.IsExistingMatchingCard((function(c) return not c:IsLinkMonster() end),tp,LOCATION_MZONE|LOCATION_PZONE,LOCATION_MZONE|LOCATION_PZONE,1,nil) then return end
	val=Duel.AnnounceNumber(tp,table.unpack(t))
	local g=Duel.SelectMatchingCard(tp,(function(c) return not c:IsLinkMonster() end),tp,LOCATION_MZONE|LOCATION_PZONE,LOCATION_MZONE|LOCATION_PZONE,0,99,nil)
	if #g>0 then
		for tc in g:Iter() do
			if tc:IsLocation(LOCATION_PZONE) then
				local e1a=Effect.CreateEffect(c)
				e1a:SetType(EFFECT_TYPE_SINGLE)
				e1a:SetCode(EFFECT_CHANGE_LSCALE)
				e1a:SetValue(val)
				e1a:SetReset(RESETS_STANDARD)
				tc:RegisterEffect(e1a)
				local e1b=e1a:Clone()
				e1b:SetCode(EFFECT_CHANGE_RSCALE)
				tc:RegisterEffect(e1b)
			else
				if val==0 then
					tc:SetStatus(STATUS_NO_LEVEL,true)
				else
					tc:SetStatus(STATUS_NO_LEVEL,false)
				end
				if tc:HasRank() then
					setcode=EFFECT_CHANGE_RANK_FINAL
				else
					setcode=EFFECT_CHANGE_LEVEL_FINAL
				end
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(setcode)
				e1:SetValue(val)
				e1:SetReset(RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end
function s.rcatt_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=nil
	local rcatt=nil
	if not Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then return end
	op=Duel.SelectOption(tp,aux.Stringid(id,10),aux.Stringid(id,11),aux.Stringid(id,15))
	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
		rcatt=Duel.AnnounceRace(tp,1,0xFFFFFFFF)
	elseif op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
		rcatt=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	else
		return false
	end
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,0,99,nil)
	if #g>0 then
		for tc in g:Iter() do
			if op==0 then
				setcode=EFFECT_CHANGE_RACE
			elseif op==1 then
				setcode=EFFECT_CHANGE_ATTRIBUTE
			end
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(setcode)
			e1:SetValue(rcatt)
			e1:SetReset(RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
function s.dice_op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		local res={}
		local ct=ev
		local t={}
		for i=1,100 do
			t[i]=i
		end
		for i=1,ct do
			local dice=Duel.AnnounceNumber(tp,table.unpack(t))
			table.insert(res,dice)
		end
		Duel.SetDiceResult(table.unpack(res))
		local str=""
		for i,v in ipairs(res) do
    			if i>1 then
        			str=str .. " "
   	 		end
    		str=str .. "[" .. v .. "]"
		end
		Debug.ShowHint("주사위 결과: " .. str)
	end
end
function s.coin_op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		local res={}
		local ct=ev
		for i=1,ct do
			local coin=Duel.AnnounceCoin(tp)
			if coin==COIN_HEADS then
				table.insert(res,COIN_HEADS)
			else
				table.insert(res,COIN_TAILS)
			end
		end
		local str=""
		Duel.SetCoinResult(table.unpack(res))
		for i,v in ipairs(res) do
			if i>1 then
				str=str .. " "
			end
			if v==COIN_HEADS then
				str=str .. "[앞면]"
			else
				str=str .. "[뒷면]"
			end
		end
		Debug.ShowHint("코인 토스 결과: " .. str)
	end
end