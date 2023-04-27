--전기양의 잠꼬대
local m=47250054
local cm=_G["c"..m]

function cm.initial_effect(c)
	
	--Effect_01
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,m)
	e1:SetTarget(cm.thtg)
	e1:SetOperation(cm.thop)
	c:RegisterEffect(e1)

	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,m)
	e3:SetTarget(cm.drtg)
	e3:SetOperation(cm.drop)
	c:RegisterEffect(e3)

end


function cm.thfilter2(c)
	return c:IsAbleToHand() and c:GetSequence()<5
end
function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and cm.thfilter2(chkc) and not chkc==e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(cm.thfilter2,tp,LOCATION_SZONE,LOCATION_SZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,cm.thfilter2,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function cm.spfilter(c,e,tp)
	return c:IsSetCard(0xe2e) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()

	if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then

		local g=Duel.GetMatchingGroup(cm.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)

		if #g>0 and tc:IsLocation(LOCATION_HAND) and Duel.GetLocationCountFromEx(tp,tp,e:GetHandler())>0 then

			if Duel.SelectYesNo(tp,aux.Stringid(m,0)) then

				local spg=Duel.SelectMatchingCard(tp,cm.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)

				if #spg>0 then
					Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
				end

			end
		end
	end
end


function cm.tdfilter(c)
	return c:IsSetCard(0xe2e) and c:IsAbleToDeck() and c:IsType(TYPE_MONSTER) and ((c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()) or c:IsLocation(LOCATION_GRAVE))
end
function cm.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cm.tdfilter(chkc) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingTarget(cm.tdfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,cm.tdfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,2,2,nil)

	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount()+1,0,0)
end
function cm.drop(e,tp,eg,ep,ev,re,r,rp)

	local c=e:GetHandler()

	if not c:IsRelateToEffect(e) then return end

	if not Duel.Draw(tp,1,REASON_EFFECT) then return end


	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)

	if c:IsLocation(LOCATION_GRAVE) then
		tg:Merge(c)
	end

	if #tg>0 then
		Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)

		local dg=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK)
		local ct=dg:FilterCount(Card.IsControler,nil,tp)

		if ct>1 then
			Duel.SortDeckbottom(tp,tp,ct)
		end
	end
end