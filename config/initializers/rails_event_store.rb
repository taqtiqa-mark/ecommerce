require 'rails_event_store'
require 'aggregate_root'
require 'arkency/command_bus'


Rails.configuration.to_prepare do
  Rails.configuration.event_store = RailsEventStore::Client.new(
    repository: RailsEventStoreActiveRecord::EventRepository.new(serializer: RubyEventStore::NULL)
  )
  Rails.configuration.command_bus = Arkency::CommandBus.new

  Rails.configuration.event_store.tap do |store|
    store.subscribe(Orders::OnOrderSubmitted, to: [Ordering::OrderSubmitted])
    store.subscribe(Orders::OnOrderExpired, to: [Ordering::OrderExpired])
    store.subscribe(Orders::OnOrderPaid, to: [Ordering::OrderPaid])
    store.subscribe(Orders::OnItemAddedToBasket, to: [Ordering::ItemAddedToBasket])
    store.subscribe(Orders::OnItemRemovedFromBasket, to: [Ordering::ItemRemovedFromBasket])

    store.subscribe(PaymentProcess, to: [
      Ordering::OrderSubmitted,
      Ordering::OrderExpired,
      Ordering::OrderPaid,
      Payments::PaymentAuthorized,
      Payments::PaymentReleased,
    ])
  end

  Rails.configuration.command_bus.tap do |bus|
    bus.register(Ordering::SubmitOrder, Ordering::OnSubmitOrder.new(number_generator: Rails.configuration.number_generator.call))
    bus.register(Ordering::SetOrderAsExpired, Ordering::OnSetOrderAsExpired.new)
    bus.register(Ordering::MarkOrderAsPaid, Ordering::OnMarkOrderAsPaid.new)
    bus.register(Ordering::AddItemToBasket, Ordering::OnAddItemToBasket.new)
    bus.register(Ordering::RemoveItemFromBasket, Ordering::OnRemoveItemFromBasket.new)
    bus.register(Payments::AuthorizePayment, Payments::OnAuthorizePayment.new)
    bus.register(Payments::CapturePayment, Payments::OnCapturePayment.new)
    bus.register(Payments::ReleasePayment, Payments::OnReleasePayment.new)
  end
end
