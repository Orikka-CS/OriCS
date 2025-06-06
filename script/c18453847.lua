--원수 갚은 두루미
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,99,s.pfil1)
	local e1=MakeEff(c,"SC")
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	WriteEff(e1,1,"NO")
	c:RegisterEffect(e1)
	local e4=MakeEff(c,"Qo","M")
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetCountLimit(1)
	WriteEff(e4,4,"TO")
	c:RegisterEffect(e4)
end
s.listed_names={30914564}
function s.pfil1(g)
	return g:IsExists(Card.IsCode,1,nil,30914564)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetTarget(s.otar11)
	Duel.RegisterEffect(e1,tp)
end
function s.otar11(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(id) and sumtype&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK
end
function s.tfil4(c,e,tp,zone)
	return (c:IsCode(30914564) or aux.IsCodeListed(c,30914564)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	if chkc then
		return chkc:IsLoc("G") and chkc:IsControler(tp) and s.tfil4(chkc,e,tp,zone)
	end
	if chk==0 then
		return zone~=0 and Duel.IETarget(s.tfil4,tp,"G",0,1,nil,e,tp,zone)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local ct=Duel.GetLocCount(tp,"M",tp,LOCATION_REASON_TOFIELD,zone)
	local g=Duel.STarget(tp,s.tfil4,tp,"G",0,1,ct,nil,e,tp,zone)
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	if not c:IsRelateToEffect(e) or zone==0 then
		return
	end
	local g=Duel.GetTargetCards(e)
	local ct=Duel.GetLocCount(tp,"M",tp,LOCATION_REASON_TOFIELD,zone)
	if ct<1 then
		return
	end
	if ct>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		ct=1
	end
	if #g>ct then
		g=g:Select(tp,ct,ct,nil)
	end
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end