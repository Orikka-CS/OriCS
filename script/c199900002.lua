--산수교실
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCountLimit(1)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCountLimit(1)
	e3:SetTarget(s.tar3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(0xff,0xff)
	e4:SetOperation(s.op4)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_XYZ_LEVEL)
	e5:SetRange(LOCATION_FZONE)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetTargetRange(0xff,0xff)
	e5:SetValue(s.val5)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(86466163)
	e6:SetLabelObject(e5)
	e6:SetValue(s.val6)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e7:SetRange(LOCATION_FZONE)
	e7:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e7:SetTargetRange(0xff,0xff)
	e7:SetTarget(s.tar7)
	e7:SetValue(s.val7)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e8:SetValue(s.val8)
	c:RegisterEffect(e8)
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_SYNCHRO_LEVEL)
	e9:SetRange(LOCATION_FZONE)
	e9:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e9:SetTargetRange(0xff,0xff)
	e9:SetTarget(s.tar9)
	e9:SetValue(999)
	c:RegisterEffect(e9)
end
s.listed_names={199900000}
function s.tfil2(c)
	return c:IsCode(199900000) and c:IsAbleToHand()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil2,tp,LOCATION_DECK+LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tfil2),tp,LOCATION_DECK+LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.tfil3(c,mg)
	return c:IsSynchroSummonable(nil,mg) or c:IsXyzSummonable(nil,mg)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,TYPE_MONSTER)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil3,tp,LOCATION_EXTRA,0,1,nil,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,TYPE_MONSTER)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.tfil3,tp,LOCATION_EXTRA,0,1,1,nil,mg)
	local tc=sg:GetFirst()
	if tc then
		if tc:IsSynchroSummonable(nil,mg) then
			Duel.SynchroSummon(tp,tc,nil,mg)
		elseif tc:IsXyzSummonable(nil,mg) then
			Duel.XyzSummon(tp,tc,nil,mg,1,99)
		end
	end
end
function s.op4(e,tg,ntg,sg,lv,sc,tp)
	local chk=sg:IsExists(Card.IsCode,1,nil,199900000)
	local res=(chk and lv==9)
		or (not chk and sg:CheckWithSumEqual(Card.GetSynchroLevel,lv,#sg,#sg,sc))
	return res,true
end
function Xyz.MatNumChkF2(tg,lv,xyz)
	local chkg=tg:Filter(Card.IsHasEffect,nil,86466163)
	for chkc in aux.Next(chkg) do
		local rev={}
		for _,te in ipairs({chkc:GetCardEffect(86466163)}) do
			local val=te:GetValue()
			if type(val)=="number" then
				local rct=te:GetValue()&0xffff
				local comp=te:GetValue()>>16
				if not Xyz.MatNumChk(tg:FilterCount(Card.IsMonster,nil),rct,comp) then
					local con=te:GetLabelObject():GetCondition()
					if not con then
						con=aux.TRUE
					end
					if not rev[te] then
						table.insert(rev,te)
						rev[te]=con
						te:GetLabelObject():SetCondition(aux.FALSE)
					end
				end
			elseif type(val)=="function" then
				if not val(te,tg) then
					local con=te:GetLabelObject():GetCondition()
					if not con then
						con=aux.TRUE
					end
					if not rev[te] then
						table.insert(rev,te)
						rev[te]=con
						te:GetLabelObject():SetCondition(aux.FALSE)
					end
				end
			end
		end
		if #rev>0 then
			local islv=chkc:IsXyzLevel(xyz,lv)
			for _,te in ipairs(rev) do
				local con=rev[te]
				te:GetLabelObject():SetCondition(con)
			end
			if not islv then
				return false
			end
		end
	end
	return true
end
function s.val5(e,c,rc)
	return 0x90000+c:GetLevel()
end
function s.val6(e,mg)
	return mg:IsExists(Card.IsCode,1,nil,199900000)
end
function s.tar7(e,c)
	return c:IsCode(199900000)
end
function s.val7(e,c)
	if not c then
		return false
	end
	return not c:IsRank(9)
end
function s.val8(e,c)
	if not c then
		return false
	end
	return not c:IsLevel(9)
end
function s.tar9(e,c)
	return not c:HasLevel()
end
local cicbsm=Card.IsCanBeSynchroMaterial
function Card.IsCanBeSynchroMaterial(c,sc,...)
	if c:Type()&TYPE_XYZ~=0 and c:IsHasEffect(EFFECT_SYNCHRO_LEVEL) then
		--not fully implemented
		return true
	end
	return cicbsm(c,sc,...)
end