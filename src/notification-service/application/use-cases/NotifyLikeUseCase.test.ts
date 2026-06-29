import { NotifyLikeUseCase } from "./NotifyLikeUseCase";
import { NotificationSender } from "../ports/NotificationSender";

describe("Notification Service NotifyLikeUseCase", () => {
  it("sends a LIKE notification to the target user", () => {
    const sender: jest.Mocked<NotificationSender> = {
      send: jest.fn(),
    };

    const useCase = new NotifyLikeUseCase(sender);

    useCase.execute({
      fromUserId: "user-1",
      toUserId: "user-2",
      isSuperLike: true,
    });

    expect(sender.send).toHaveBeenCalledTimes(1);

    const notification = sender.send.mock.calls[0][0];
    expect(notification.type).toBe("LIKE");
    expect(notification.recipients.map((recipient) => recipient.toString())).toEqual([
      "user-2",
    ]);
    expect(notification.payload).toEqual({
      fromUserId: "user-1",
      isSuperLike: true,
    });
    expect(notification.occurredAt).toBeInstanceOf(Date);
  });
});
