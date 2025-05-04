--태양보다 더 뜨거운 사랑
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"S","M")
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCondition(s.con1)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"STo")
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	if not s.global_check then
		s.global_check=true
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_STARTUP)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
	end
end
s.listed_names={54493213}
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		if not s[p] then
			local token=Duel.CreateToken(p,id)
			token:Type(0)
			s[p]=token
		end
	end
end
function s.con1(e)
	local res={}
	for p=0,1 do
		local tc=s[p]
		local eset={tc:IsHasEffect(EFFECT_TO_GRAVE_REDIRECT)}
		for _,te in ipairs(eset) do
			if te:GetValue()==LSTN("R") then
				local tg=te:GetTarget()
				if not tg or tg(te,tc) then
					res[p]=true
				end
			end
		end
	end
	return res[0] and res[1]
end
function s.val1(e,c)
	local tp=e:GetHandlerPlayer()
	return Duel.GetFieldGroupCount(tp,LSTN("R"),LSTN("R"))*100
end
function s.tfil31(c,tp)
	return c:ListsCode(54493213) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
		and c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_TRAP)
		and not Duel.IEMCard(s.tfil32,tp,"O",0,1,nil,c:GetCode())
end
function s.tfil32(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocCount(tp,"S")>0 and Duel.IEMCard(s.tfil31,tp,"D",0,1,nil,tp)
	end
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocCount(tp,"S")>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SMCard(tp,s.tfil31,tp,"D",0,1,1,nil,tp)
		local tc=g:GetFirst()
		if tc then
			Duel.MoveToField(tc,tp,tp,LSTN("S"),POS_FACEUP,true)
		end
	end
end